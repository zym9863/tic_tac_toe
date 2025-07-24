import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

// Define custom colors for our app
class AppColors {
  // Primary gradient colors - Modern purple to blue
  static const Color primaryColor = Color(0xFF667EEA); // Soft purple-blue
  static const Color secondaryColor = Color(0xFF764BAF); // Deep purple
  static const Color accentColor = Color(0xFFFF6B9D); // Pink accent
  
  // Background colors
  static const Color backgroundColor = Color(0xFFF8FAFC); // Very light blue-gray
  static const Color cardColor = Color(0xFFFFFFFF); // Pure white
  
  // Game piece colors - More vibrant and distinct
  static const Color xColor = Color(0xFF10B981); // Emerald green
  static const Color oColor = Color(0xFFF59E0B); // Amber orange
  
  // UI element colors
  static const Color gridColor = Color(0xFF475569); // Slate gray
  static const Color textColor = Color(0xFF1E293B); // Dark slate
  
  // Interactive states
  static const Color hoverColor = Color(0xFFE2E8F0); // Light gray for hover
  static const Color winningColor = Color(0xFFEF4444); // Red for winning highlight
  
  // Shadow colors
  static const Color shadowColor = Color(0x1A000000); // Subtle shadow
  static const Color strongShadowColor = Color(0x2A000000); // Stronger shadow
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor,
          primary: AppColors.primaryColor,
          secondary: AppColors.secondaryColor,
          surface: AppColors.cardColor,
          background: AppColors.backgroundColor,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: AppColors.shadowColor,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          shadowColor: AppColors.shadowColor,
        ),
      ),
      home: const TicTacToeGame(),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame>
    with TickerProviderStateMixin {
  // Game board: null = empty, true = X, false = O
  List<List<bool?>> board = List.generate(3, (_) => List.filled(3, null));

  // Current player: true = X, false = O
  bool currentPlayer = true;

  // Scores
  int xScore = 0;
  int oScore = 0;

  // Game status
  bool gameOver = false;
  String statusMessage = "Player X's turn";
  
  // Winning line tracking
  List<List<int>>? winningLine;

  // Animation controllers for cell animations
  List<List<AnimationController?>> cellAnimationControllers =
      List.generate(3, (_) => List.filled(3, null));
      
  // Animation controller for winning line
  late AnimationController winningLineAnimationController;
  
  // Animation controller for celebration
  late AnimationController celebrationAnimationController;

  @override
  void initState() {
    super.initState();
    // Initialize animation controllers for each cell
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        cellAnimationControllers[row][col] = AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        );
      }
    }
    
    // Initialize winning line animation controller
    winningLineAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Initialize celebration animation controller
    celebrationAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    // Dispose animation controllers
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        cellAnimationControllers[row][col]?.dispose();
      }
    }
    winningLineAnimationController.dispose();
    celebrationAnimationController.dispose();
    super.dispose();
  }

  // Handle cell tap
  void _handleCellTap(int row, int col) {
    // Ignore taps if the cell is already filled or game is over
    if (board[row][col] != null || gameOver) {
      return;
    }

    setState(() {
      // Set the cell to the current player
      board[row][col] = currentPlayer;
      
      // Trigger animation for the cell
      cellAnimationControllers[row][col]?.forward();

      // Check for win
      if (_checkWin(row, col)) {
        gameOver = true;
        winningLineAnimationController.forward();
        celebrationAnimationController.forward();
        if (currentPlayer) {
          xScore++;
          statusMessage = "Player X wins!";
        } else {
          oScore++;
          statusMessage = "Player O wins!";
        }
        return;
      }

      // Check for draw
      if (_checkDraw()) {
        gameOver = true;
        statusMessage = "It's a draw!";
        return;
      }

      // Switch player
      currentPlayer = !currentPlayer;
      statusMessage = "Player ${currentPlayer ? 'X' : 'O'}'s turn";
    });
  }

  // Check if the current move results in a win
  bool _checkWin(int row, int col) {
    // Check row
    if (board[row].every((cell) => cell == currentPlayer)) {
      winningLine = [[row, 0], [row, 1], [row, 2]];
      return true;
    }

    // Check column
    if (board.every((r) => r[col] == currentPlayer)) {
      winningLine = [[0, col], [1, col], [2, col]];
      return true;
    }

    // Check main diagonal
    if (row == col &&
        board[0][0] == currentPlayer &&
        board[1][1] == currentPlayer &&
        board[2][2] == currentPlayer) {
      winningLine = [[0, 0], [1, 1], [2, 2]];
      return true;
    }

    // Check anti-diagonal
    if (row + col == 2 &&
        board[0][2] == currentPlayer &&
        board[1][1] == currentPlayer &&
        board[2][0] == currentPlayer) {
      winningLine = [[0, 2], [1, 1], [2, 0]];
      return true;
    }

    return false;
  }

  // Check if a cell is part of the winning line
  bool _isWinningCell(int row, int col) {
    if (winningLine == null) return false;
    return winningLine!.any((cell) => cell[0] == row && cell[1] == col);
  }

  // Check if the game is a draw
  bool _checkDraw() {
    for (var row in board) {
      for (var cell in row) {
        if (cell == null) {
          return false;
        }
      }
    }
    return true;
  }

  // Reset the game
  void _resetGame() {
    setState(() {
      board = List.generate(3, (_) => List.filled(3, null));
      gameOver = false;
      statusMessage = "Player X's turn";
      currentPlayer = true;
      winningLine = null;
      
      // Reset all cell animations
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          cellAnimationControllers[row][col]?.reset();
        }
      }
      
      // Reset winning line animation
      winningLineAnimationController.reset();
      
      // Reset celebration animation
      celebrationAnimationController.reset();
    });
  }

  // Reset scores and game
  void _resetScores() {
    setState(() {
      xScore = 0;
      oScore = 0;
      _resetGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Tic Tac Toe',
          style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundColor,
              Color(0xFFEDF2F7),
            ],
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Score board
                Container(
                  margin: const EdgeInsets.all(20.0),
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 28.0,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.strongShadowColor,
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildScoreColumn(
                    'Player X',
                    xScore,
                    AppColors.xColor,
                    FontAwesomeIcons.xmark,
                  ),
                  Container(
                    height: 60,
                    width: 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  _buildScoreColumn(
                    'Player O',
                    oScore,
                    AppColors.oColor,
                    FontAwesomeIcons.circle,
                  ),
                ],
              ),
            ),

          // Status message
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16.0),
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 28.0,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  statusMessage,
                  textStyle: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: currentPlayer ? AppColors.xColor : AppColors.oColor,
                  ),
                  speed: const Duration(milliseconds: 80),
                ),
              ],
              totalRepeatCount: 1,
              displayFullTextOnTap: true,
            ),
          ),

          // Game board
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            constraints: const BoxConstraints(maxWidth: 350, maxHeight: 350),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.strongShadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: List.generate(3, (row) {
                      return Expanded(
                        child: Row(
                          children: List.generate(3, (col) {
                            return Expanded(
                              child: AnimatedBuilder(
                                animation: cellAnimationControllers[row][col]!,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 1.0 + (cellAnimationControllers[row][col]!.value * 0.1),
                                    child: GestureDetector(
                                      onTap: () => _handleCellTap(row, col),
                                      child: Container(
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: _isWinningCell(row, col)
                                              ? AppColors.winningColor.withOpacity(0.2)
                                              : board[row][col] != null
                                                  ? (board[row][col]! 
                                                      ? AppColors.xColor.withOpacity(0.1)
                                                      : AppColors.oColor.withOpacity(0.1))
                                                  : AppColors.backgroundColor,
                                          borderRadius: BorderRadius.circular(12),
                                          border: _isWinningCell(row, col)
                                              ? Border.all(
                                                  color: AppColors.winningColor,
                                                  width: 3,
                                                )
                                              : board[row][col] != null
                                                  ? Border.all(
                                                      color: board[row][col]!
                                                          ? AppColors.xColor
                                                          : AppColors.oColor,
                                                      width: 2,
                                                    )
                                                  : null,
                                          boxShadow: [
                                            BoxShadow(
                                              color: _isWinningCell(row, col)
                                                  ? AppColors.winningColor.withOpacity(0.4)
                                                  : AppColors.shadowColor,
                                              blurRadius: 4 + (cellAnimationControllers[row][col]!.value * 4) +
                                                  (_isWinningCell(row, col) ? 8 * winningLineAnimationController.value : 0),
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: _buildCellContent(row, col),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 16),
                  label: Text(
                    'New Game',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _resetScores,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(FontAwesomeIcons.trash, size: 16),
                  label: Text(
                    'Reset Scores',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Celebration animation overlay
      if (gameOver && winningLine != null)
        AnimatedBuilder(
          animation: celebrationAnimationController,
          builder: (context, child) {
            return Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: ConfettiPainter(celebrationAnimationController.value),
                  size: Size.infinite,
                ),
              ),
            );
          },
        ),
    ],
  ),
    ),
  );
}

  // Helper method to build score column
  Widget _buildScoreColumn(
    String player,
    int score,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              player,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '$score',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build the content of a cell (X, O, or empty)
  Widget _buildCellContent(int row, int col) {
    if (board[row][col] == null) {
      return const SizedBox();
    }
    
    final animationController = cellAnimationControllers[row][col]!;
    final isX = board[row][col]!;
    
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: animationController.value,
          child: Transform.rotate(
            angle: animationController.value * (isX ? 0.3 : 0),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isX 
                    ? AppColors.xColor.withOpacity(0.15)
                    : AppColors.oColor.withOpacity(0.15),
                border: Border.all(
                  color: isX ? AppColors.xColor : AppColors.oColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isX ? AppColors.xColor : AppColors.oColor)
                        .withOpacity(0.3),
                    blurRadius: 6 * animationController.value,
                    spreadRadius: 2 * animationController.value,
                  ),
                ],
              ),
              child: Icon(
                isX ? FontAwesomeIcons.xmark : FontAwesomeIcons.circle,
                size: isX ? 32 : 28,
                color: isX ? AppColors.xColor : AppColors.oColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom painter for confetti celebration animation
class ConfettiPainter extends CustomPainter {
  final double animationValue;
  
  ConfettiPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    if (animationValue == 0) return;
    
    final paint = Paint();
    final random = Random(42); // Fixed seed for consistent animation
    
    // Create confetti particles
    for (int i = 0; i < 30; i++) {
      final progress = (animationValue + (i * 0.1)) % 1.0;
      final x = random.nextDouble() * size.width;
      final startY = -20.0;
      final endY = size.height + 20.0;
      final currentY = startY + (endY - startY) * progress;
      
      // Different colors for confetti
      final colors = [
        AppColors.xColor,
        AppColors.oColor,
        AppColors.accentColor,
        AppColors.primaryColor,
        AppColors.secondaryColor,
      ];
      
      paint.color = colors[i % colors.length].withOpacity(0.8);
      
      // Different shapes for confetti
      if (i % 3 == 0) {
        // Rectangle confetti
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, currentY),
            width: 8,
            height: 12,
          ),
          paint,
        );
      } else if (i % 3 == 1) {
        // Circle confetti
        canvas.drawCircle(
          Offset(x, currentY),
          4,
          paint,
        );
      } else {
        // Triangle confetti
        final path = Path();
        path.moveTo(x, currentY - 6);
        path.lineTo(x - 4, currentY + 6);
        path.lineTo(x + 4, currentY + 6);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

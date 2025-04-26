import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

// Define custom colors for our app
class AppColors {
  static const Color primaryColor = Color(0xFF6A5ACD); // SlateBlue
  static const Color secondaryColor = Color(0xFF9370DB); // MediumPurple
  static const Color accentColor = Color(0xFFFF6B6B); // Coral
  static const Color backgroundColor = Color(0xFFF5F5F5); // WhiteSmoke
  static const Color xColor = Color(0xFF4CAF50); // Green
  static const Color oColor = Color(0xFFFF9800); // Orange
  static const Color gridColor = Color(0xFF424242); // Dark Gray
  static const Color textColor = Color(0xFF333333); // Dark Text
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
          surface: AppColors.backgroundColor,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
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

class _TicTacToeGameState extends State<TicTacToeGame> {
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

  // Handle cell tap
  void _handleCellTap(int row, int col) {
    // Ignore taps if the cell is already filled or game is over
    if (board[row][col] != null || gameOver) {
      return;
    }

    setState(() {
      // Set the cell to the current player
      board[row][col] = currentPlayer;

      // Check for win
      if (_checkWin(row, col)) {
        gameOver = true;
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
      return true;
    }

    // Check column
    if (board.every((r) => r[col] == currentPlayer)) {
      return true;
    }

    // Check diagonals
    if (row == col &&
        board[0][0] == currentPlayer &&
        board[1][1] == currentPlayer &&
        board[2][2] == currentPlayer) {
      return true;
    }

    if (row + col == 2 &&
        board[0][2] == currentPlayer &&
        board[1][1] == currentPlayer &&
        board[2][0] == currentPlayer) {
      return true;
    }

    return false;
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
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Score board
          Container(
            margin: const EdgeInsets.all(20.0),
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 24.0,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryColor, AppColors.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(51),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
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
                  height: 50,
                  width: 2,
                  color: Colors.white.withAlpha(128),
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
              vertical: 12.0,
              horizontal: 24.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  statusMessage,
                  textStyle: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: currentPlayer ? AppColors.xColor : AppColors.oColor,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              totalRepeatCount: 1,
              displayFullTextOnTap: true,
            ),
          ),

          // Game board
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            constraints: const BoxConstraints(maxWidth: 320, maxHeight: 320),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withAlpha(77),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Column(
                  children: List.generate(3, (row) {
                    return Expanded(
                      child: Row(
                        children: List.generate(3, (col) {
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => _handleCellTap(row, col),
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      board[row][col] != null
                                          ? Border.all(
                                            color:
                                                board[row][col]!
                                                    ? AppColors.xColor
                                                    : AppColors.oColor,
                                            width: 2,
                                          )
                                          : null,
                                ),
                                child: Center(
                                  child: _buildCellContent(row, col),
                                ),
                              ),
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
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
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
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$score',
              style: GoogleFonts.poppins(
                fontSize: 22,
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
    } else if (board[row][col]!) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.xColor.withAlpha(26),
        ),
        child: const Icon(
          FontAwesomeIcons.xmark,
          size: 40,
          color: AppColors.xColor,
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.oColor.withAlpha(26),
        ),
        child: const Icon(
          FontAwesomeIcons.circle,
          size: 36,
          color: AppColors.oColor,
        ),
      );
    }
  }
}

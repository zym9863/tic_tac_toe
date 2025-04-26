// This is a basic Flutter widget test for the Tic Tac Toe game.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tic_tac_toe/main.dart';

void main() {
  testWidgets('Tic Tac Toe game basic test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title is correct
    expect(find.text('Tic Tac Toe'), findsOneWidget);

    // Verify that the initial player is X
    expect(find.text("Player X's turn"), findsOneWidget);

    // Verify that the score starts at 0
    expect(
      find.text('0'),
      findsAtLeastNWidgets(2),
    ); // Both X and O scores are 0

    // Verify that the game board is empty (no X or O)
    expect(find.text('X'), findsNothing);
    expect(find.text('O'), findsNothing);

    // Verify that the buttons are present
    expect(find.text('New Game'), findsOneWidget);
    expect(find.text('Reset Scores'), findsOneWidget);
  });

  testWidgets('Tic Tac Toe gameplay test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Find the first cell (top-left) and tap it
    final firstCell = find.byType(GestureDetector).first;
    await tester.tap(firstCell);
    await tester.pump();

    // Verify that X appears and it's O's turn
    expect(find.text('X'), findsOneWidget);
    expect(find.text("Player O's turn"), findsOneWidget);

    // Find the second cell and tap it
    final secondCell = find.byType(GestureDetector).at(1);
    await tester.tap(secondCell);
    await tester.pump();

    // Verify that O appears and it's X's turn
    expect(find.text('O'), findsOneWidget);
    expect(find.text("Player X's turn"), findsOneWidget);
  });
}

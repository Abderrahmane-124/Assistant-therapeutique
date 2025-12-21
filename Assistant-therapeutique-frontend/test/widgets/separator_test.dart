import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/features/auth/widgets/separator.dart';

void main() {
  group('SeparatorLine Widget', () {
    testWidgets('devrait afficher le texte "OU"', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SeparatorLine(),
          ),
        ),
      );

      // Assert
      expect(find.text('OU'), findsOneWidget);
    });

    testWidgets('devrait contenir deux Dividers', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SeparatorLine(),
          ),
        ),
      );

      // Assert
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('devrait contenir un Row', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SeparatorLine(),
          ),
        ),
      );

      // Assert
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('devrait avoir le texte coloré en gris', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SeparatorLine(),
          ),
        ),
      );

      // Assert
      final textWidget = tester.widget<Text>(find.text('OU'));
      expect(textWidget.style?.color, equals(Colors.grey));
    });

    testWidgets('devrait s\'étendre sur toute la largeur', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: SeparatorLine(),
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Expanded), findsNWidgets(2));
    });
  });
}

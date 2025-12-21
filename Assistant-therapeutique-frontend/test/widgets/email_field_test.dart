import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/features/auth/widgets/email_field.dart';

void main() {
  group('EmailField Widget', () {
    testWidgets('devrait afficher le TextField avec les bonnes propriétés', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmailField(),
          ),
        ),
      );

      // Assert
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('devrait afficher le label "Email"', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmailField(),
          ),
        ),
      );

      // Assert
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('devrait afficher le hint text "exemple@email.com"', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmailField(),
          ),
        ),
      );

      // Assert
      expect(find.text('exemple@email.com'), findsOneWidget);
    });

    testWidgets('devrait afficher l\'icône email', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmailField(),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('devrait permettre la saisie de texte', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmailField(),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'test@example.com');
      await tester.pump();

      // Assert
      expect(find.text('test@example.com'), findsOneWidget);
    });
  });
}

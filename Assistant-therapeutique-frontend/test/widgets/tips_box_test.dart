import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/features/auth/widgets/tips_box.dart';

void main() {
  group('TipsBox Widget', () {
    testWidgets('devrait afficher le texte fourni', (WidgetTester tester) async {
      // Arrange
      const testText = 'Voici un conseil utile';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TipsBox(text: testText),
          ),
        ),
      );

      // Assert
      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('devrait afficher l\'icône ampoule', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TipsBox(text: 'Test'),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
    });

    testWidgets('devrait utiliser la couleur ambre pour l\'icône', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TipsBox(text: 'Test'),
          ),
        ),
      );

      // Assert
      final icon = tester.widget<Icon>(find.byIcon(Icons.lightbulb));
      expect(icon.color, equals(Colors.amber));
    });

    testWidgets('devrait afficher un texte long correctement', (WidgetTester tester) async {
      // Arrange
      const longText = 'Ce conseil est très long et devrait s\'étendre sur plusieurs lignes pour tester que le widget gère correctement le débordement de texte et reste lisible.';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: TipsBox(text: longText),
            ),
          ),
        ),
      );

      // Assert - Le texte doit être présent
      expect(find.text(longText), findsOneWidget);
    });

    testWidgets('devrait afficher un texte court', (WidgetTester tester) async {
      // Arrange
      const shortText = 'Tip';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TipsBox(text: shortText),
          ),
        ),
      );

      // Assert
      expect(find.text(shortText), findsOneWidget);
    });

    testWidgets('devrait gérer les caractères spéciaux', (WidgetTester tester) async {
      // Arrange
      const specialText = "Conseil avec des émojis 🌟 et accents éàù";

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TipsBox(text: specialText),
          ),
        ),
      );

      // Assert
      expect(find.text(specialText), findsOneWidget);
    });

    testWidgets('devrait contenir un Row comme widget parent', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TipsBox(text: 'Test'),
          ),
        ),
      );

      // Assert
      expect(find.byType(Row), findsOneWidget);
    });
  });
}

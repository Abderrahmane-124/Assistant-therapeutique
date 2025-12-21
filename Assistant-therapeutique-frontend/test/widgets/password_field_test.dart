import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/features/auth/widgets/password_field.dart';

void main() {
  group('PasswordField Widget', () {
    testWidgets('devrait afficher le TextField', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordField(),
          ),
        ),
      );

      // Assert
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('devrait afficher le label "Mot de passe"', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordField(),
          ),
        ),
      );

      // Assert
      expect(find.text('Mot de passe'), findsOneWidget);
    });

    testWidgets('devrait afficher l\'icône de verrouillage', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordField(),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('devrait avoir le texte obscurci par défaut', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordField(),
          ),
        ),
      );

      // Assert - Trouve l'icône visibility_off au départ
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('devrait basculer la visibilité lors du clic', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordField(),
          ),
        ),
      );

      // Assert - État initial: caché
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Act - Cliquer pour afficher
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Assert - État après clic: visible
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('devrait basculer deux fois pour revenir à l\'état initial', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordField(),
          ),
        ),
      );

      // Act - Premier clic
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Act - Deuxième clic
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Assert - Retour à l'état initial
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('devrait permettre la saisie de texte', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordField(),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'MonMotDePasse123');
      await tester.pump();

      // Assert
      expect(find.text('MonMotDePasse123'), findsOneWidget);
    });
  });
}

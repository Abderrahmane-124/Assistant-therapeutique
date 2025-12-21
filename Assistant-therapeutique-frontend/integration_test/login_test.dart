// Integration tests for the Login page with visual browser execution.
// These tests run in Chrome and you can see the UI interactions.
// Run with: flutter drive --driver=test_driver/integration_test.dart --target=integration_test/login_test.dart -d chrome

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moodmate/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Page Tests', () {
    // Test 1: Login sans rien entrer - doit afficher une erreur
    testWidgets('Test 1: Should show error when fields are empty', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify login page is displayed
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);

      // Tap login button without filling any fields
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      // Verify error dialog appears
      expect(find.text('Erreur'), findsOneWidget);
      expect(find.text('Veuillez remplir tous les champs'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });

    // Test 2: Login avec des credentials incorrects
    testWidgets('Test 2: Should show error with incorrect credentials', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find username field and enter incorrect username
      final usernameField = find.widgetWithText(TextField, 'Username');
      await tester.enterText(usernameField, 'wronguser');
      await tester.pumpAndSettle();

      // Find password field and enter incorrect password
      final passwordField = find.widgetWithText(TextField, 'Password');
      await tester.enterText(passwordField, 'wrongpassword');
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify error message appears (credentials incorrects)
      expect(find.text('Erreur'), findsOneWidget);

      // Close dialog if present
      final okButton = find.text('OK');
      if (okButton.evaluate().isNotEmpty) {
        await tester.tap(okButton);
        await tester.pumpAndSettle();
      }
    });

    // Test 3: Login avec credentials corrects (username: hind, password: 123)
    testWidgets('Test 3: Should login successfully and navigate to home page', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find username field and enter correct username
      final usernameField = find.widgetWithText(TextField, 'Username');
      await tester.enterText(usernameField, 'hind');
      await tester.pumpAndSettle();

      // Find password field and enter correct password
      final passwordField = find.widgetWithText(TextField, 'Password');
      await tester.enterText(passwordField, '123');
      await tester.pumpAndSettle();

      // Verify text was entered correctly
      expect(find.text('hind'), findsOneWidget);

      // Tap login button
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify navigation to home page
      // Check for home page element - 'ENREGISTRER MON HUMEUR' button
      expect(find.text('ENREGISTRER MON HUMEUR'), findsOneWidget, 
             reason: 'Home page should be displayed after successful login');
    });
  });
}

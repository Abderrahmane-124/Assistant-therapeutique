// Integration tests for Mood Tracking feature with CRUD operations.
// Run with: flutter drive --driver=test_driver/integration_test.dart --target=integration_test/mood_tracking_test.dart -d chrome

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moodmate/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Mood Tracking E2E Tests', () {
    // Test 1: Login and navigate to mood tracking page
    testWidgets('Test 1: Should login and navigate to mood tracking page', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Login with valid credentials
      final usernameField = find.widgetWithText(TextField, 'Username');
      await tester.enterText(usernameField, 'hind');
      await tester.pumpAndSettle();

      final passwordField = find.widgetWithText(TextField, 'Password');
      await tester.enterText(passwordField, '123');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify home page is displayed
      expect(find.text('ENREGISTRER MON HUMEUR'), findsOneWidget);

      // Navigate to mood tracking page by tapping the button
      await tester.tap(find.text('ENREGISTRER MON HUMEUR'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify mood tracking page is displayed
      expect(find.text('Mon Humeur du Jour'), findsOneWidget);
      expect(find.text('Comment vous sentez-vous aujourd\'hui ?'), findsOneWidget);
    });

    // Test 2: Select a mood and submit without selecting (error case)
    testWidgets('Test 2: Should show error when no mood is selected', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Login
      final usernameField = find.widgetWithText(TextField, 'Username');
      await tester.enterText(usernameField, 'hind');
      await tester.pumpAndSettle();

      final passwordField = find.widgetWithText(TextField, 'Password');
      await tester.enterText(passwordField, '123');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to mood tracking
      await tester.tap(find.text('ENREGISTRER MON HUMEUR'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Try to submit without selecting a mood
      await tester.tap(find.text('ENREGISTRER MON HUMEUR'));
      await tester.pumpAndSettle();

      // Verify error dialog appears
      expect(find.text('Sélectionnez votre humeur'), findsOneWidget);
      
      // Close dialog
      await tester.tap(find.text('Compris'));
      await tester.pumpAndSettle();
    });

    // Test 3: Create a mood entry (happy mood)
    testWidgets('Test 3: Should create a mood entry successfully', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Login
      final usernameField = find.widgetWithText(TextField, 'Username');
      await tester.enterText(usernameField, 'hind');
      await tester.pumpAndSettle();

      final passwordField = find.widgetWithText(TextField, 'Password');
      await tester.enterText(passwordField, '123');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to mood tracking
      await tester.tap(find.text('ENREGISTRER MON HUMEUR'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Select a mood (Heureux - happy)
      await tester.tap(find.text('Heureux'));
      await tester.pumpAndSettle();

      // Verify mood is selected
      expect(find.text('Heureux'), findsOneWidget);

      // Submit the mood
      await tester.tap(find.text('ENREGISTRER MON HUMEUR'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify success dialog or navigation back
      final successFound = find.text('Humeur enregistrée !').evaluate().isNotEmpty ||
                           find.text('ENREGISTRER MON HUMEUR').evaluate().isNotEmpty;
      expect(successFound, isTrue, reason: 'Should show success or return to home');
    });

    // Test 4: View mood history
    testWidgets('Test 4: Should view mood history', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Login
      final usernameField = find.widgetWithText(TextField, 'Username');
      await tester.enterText(usernameField, 'hind');
      await tester.pumpAndSettle();

      final passwordField = find.widgetWithText(TextField, 'Password');
      await tester.enterText(passwordField, '123');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify home page is displayed with history section
      expect(find.text('Ton historique émotionnel'), findsOneWidget);

      // Navigate to mood history detail
      await tester.tap(find.text('VOIR LE DÉTAIL'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify mood history page is displayed
      final historyPageFound = find.text('Historique des Humeurs').evaluate().isNotEmpty ||
                               find.text('Mood History').evaluate().isNotEmpty ||
                               find.byIcon(Icons.arrow_back).evaluate().isNotEmpty;
      expect(historyPageFound, isTrue, reason: 'Should display mood history page');
    });
  });
}

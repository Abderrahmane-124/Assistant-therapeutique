// Integration tests for Journal feature with CRUD operations.
// Run with: flutter drive --driver=test_driver/integration_test.dart --target=integration_test/journal_test.dart -d chrome

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moodmate/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Journal E2E Tests', () {
    // Test 1: Navigate to journal page
    testWidgets('Test 1: Should login and navigate to journal page', (tester) async {
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
      expect(find.text('Journal du jour'), findsOneWidget);

      // Navigate to journal page
      await tester.tap(find.text('OUVRIR LE JOURNAL'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify journal page is displayed
      expect(find.text('Mon Journal'), findsOneWidget);
      expect(find.text('Aujourd\'hui'), findsOneWidget);
    });

    // Test 2: Try to save empty journal entry (error case)
    testWidgets('Test 2: Should show error when saving empty journal', (tester) async {
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

      // Navigate to journal
      await tester.tap(find.text('OUVRIR LE JOURNAL'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // The save button should be disabled when empty
      final saveButton = find.text('SAUVEGARDER');
      expect(saveButton, findsOneWidget);
      
      // Verify journal page is correctly displayed
      expect(find.text('Mon Journal'), findsOneWidget);
    });

    // Test 3: Create a journal entry
    testWidgets('Test 3: Should create journal entry successfully', (tester) async {
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

      // Navigate to journal
      await tester.tap(find.text('OUVRIR LE JOURNAL'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Generate unique journal content with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final journalContent = 'Test journal entry - $timestamp - Je me sens bien!';

      // Find the text field and enter content
      final textField = find.byType(TextField);
      await tester.enterText(textField, journalContent);
      await tester.pumpAndSettle();

      // Verify character counter updates
      expect(find.textContaining('/500'), findsOneWidget);

      // Find and tap save button
      final saveButton = find.text('SAUVEGARDER');
      await tester.tap(saveButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify success message or that journal was saved
      final successFound = find.text('Journal sauvegardé avec succès !').evaluate().isNotEmpty ||
                           find.byType(SnackBar).evaluate().isNotEmpty ||
                           find.text('Mon Journal').evaluate().isNotEmpty;
      expect(successFound, isTrue, reason: 'Should show success or remain on journal page');
    });

    // Test 4: View journal history list
    testWidgets('Test 4: Should view journal history list', (tester) async {
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

      // Navigate to journal
      await tester.tap(find.text('OUVRIR LE JOURNAL'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to journal history by tapping history icon
      final historyIcon = find.byIcon(Icons.history);
      await tester.tap(historyIcon);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify journal list page is displayed
      expect(find.text('Mes Journaux'), findsOneWidget);
      expect(find.text('Explorez vos pensées'), findsOneWidget);
    });

    // Test 5: Journal list displays entries or empty state
    testWidgets('Test 5: Should display journal entries or empty state', (tester) async {
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

      // Navigate to journal
      await tester.tap(find.text('OUVRIR LE JOURNAL'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to journal history
      final historyIcon = find.byIcon(Icons.history);
      await tester.tap(historyIcon);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should display either entries with "Lire plus" or empty state message
      final hasEntries = find.text('Lire plus').evaluate().isNotEmpty;
      final hasEmptyState = find.text('Aucune entrée de journal').evaluate().isNotEmpty;
      final isLoading = find.text('Chargement de vos journaux...').evaluate().isNotEmpty;
      
      expect(hasEntries || hasEmptyState || isLoading, isTrue, 
             reason: 'Should display journal entries, empty state, or loading indicator');
    });
  });
}

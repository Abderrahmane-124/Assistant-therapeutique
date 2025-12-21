// Integration tests for complete user flow.
// Run with: flutter drive --driver=test_driver/integration_test.dart --target=integration_test/user_flow_test.dart -d chrome

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moodmate/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete User Flow E2E Tests', () {
    // Test: Complete user journey - Login -> Record Mood -> Journal -> Wellness
    testWidgets('Complete user flow: Login -> Mood -> Journal -> Back to Home', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ========== STEP 1: LOGIN ==========
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);

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
      expect(find.text('Journal du jour'), findsOneWidget);

      // ========== STEP 2: RECORD MOOD ==========
      await tester.tap(find.text('ENREGISTRER MON HUMEUR'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Mon Humeur du Jour'), findsOneWidget);

      // Select a mood (Content)
      await tester.tap(find.text('Content'));
      await tester.pumpAndSettle();

      // Submit mood
      await tester.tap(find.text('ENREGISTRER MON HUMEUR'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Close success dialog and go back
      final retourButton = find.text('Retour');
      if (retourButton.evaluate().isNotEmpty) {
        await tester.tap(retourButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Navigate back if needed
      if (find.text('ENREGISTRER MON HUMEUR').evaluate().isEmpty) {
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      // ========== STEP 3: OPEN JOURNAL ==========
      await tester.tap(find.text('OUVRIR LE JOURNAL'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Mon Journal'), findsOneWidget);

      // Create a journal entry
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final journalContent = 'User flow test - $timestamp';

      final textField = find.byType(TextField);
      await tester.enterText(textField, journalContent);
      await tester.pumpAndSettle();

      // Save journal
      await tester.tap(find.text('SAUVEGARDER'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate back to home
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // ========== STEP 4: VERIFY HOME PAGE ==========
      final homePageElements = find.text('ENREGISTRER MON HUMEUR').evaluate().isNotEmpty ||
                               find.text('Ton historique émotionnel').evaluate().isNotEmpty ||
                               find.text('Journal du jour').evaluate().isNotEmpty;
      
      expect(homePageElements, isTrue, reason: 'Should be back on home page');
    });

    // Test: Navigate through all main features
    testWidgets('Navigate through all main features from home', (tester) async {
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

      // Verify all main sections are visible
      expect(find.text('ENREGISTRER MON HUMEUR'), findsOneWidget);
      expect(find.text('Ton historique émotionnel'), findsOneWidget);
      expect(find.text('Journal du jour'), findsOneWidget);
      expect(find.text('Recommandations pour toi'), findsOneWidget);

      // Verify filter buttons
      expect(find.text('Semaine'), findsOneWidget);
      expect(find.text('Mois'), findsOneWidget);
      expect(find.text('Année'), findsOneWidget);

      // Verify action buttons
      expect(find.text('VOIR LE DÉTAIL'), findsOneWidget);
      expect(find.text('OUVRIR LE JOURNAL'), findsOneWidget);
    });

    // Test: Profile navigation
    testWidgets('Navigate to profile page', (tester) async {
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

      // Navigate to profile
      final profileIcon = find.byIcon(Icons.person_outline);
      await tester.tap(profileIcon);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify profile page is displayed
      final profilePageFound = find.text('Profil').evaluate().isNotEmpty ||
                               find.text('Profile').evaluate().isNotEmpty ||
                               find.text('Déconnexion').evaluate().isNotEmpty ||
                               find.text('Logout').evaluate().isNotEmpty ||
                               find.byIcon(Icons.logout).evaluate().isNotEmpty;
      
      expect(profilePageFound, isTrue, reason: 'Should display profile page');
    });
  });
}

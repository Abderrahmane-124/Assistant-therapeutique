// Integration tests for Wellness features (Meditation & Breathing).
// Run with: flutter drive --driver=test_driver/integration_test.dart --target=integration_test/wellness_test.dart -d chrome

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moodmate/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Wellness E2E Tests', () {
    // Test 1: Navigate to Meditation page
    testWidgets('Test 1: Should navigate to meditation page', (tester) async {
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

      // Verify home page shows recommendations
      expect(find.text('Recommandations pour toi'), findsOneWidget);

      // Scroll down to find the meditation card
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Navigate to meditation page
      await tester.tap(find.text('Méditation 2 min'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify meditation page is displayed
      expect(find.text('Méditation 2 min'), findsOneWidget);
      expect(find.text('Relaxation guidée'), findsOneWidget);
      expect(find.text('Démarrer'), findsOneWidget);
    });

    // Test 2: Start and pause meditation
    testWidgets('Test 2: Should start and pause meditation', (tester) async {
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

      // Scroll and navigate to meditation
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Méditation 2 min'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify initial timer shows 2:00
      expect(find.text('2:00'), findsOneWidget);

      // Start meditation
      await tester.tap(find.text('Démarrer'));
      await tester.pump(const Duration(seconds: 2));

      // Verify button changes to Pause
      expect(find.text('Pause'), findsOneWidget);

      // Pause meditation
      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();

      // Verify button changes back to Démarrer
      expect(find.text('Démarrer'), findsOneWidget);
    });

    // Test 3: Reset meditation timer
    testWidgets('Test 3: Should reset meditation timer', (tester) async {
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

      // Scroll and navigate to meditation
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Méditation 2 min'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Start meditation
      await tester.tap(find.text('Démarrer'));
      await tester.pump(const Duration(seconds: 3));

      // Reset timer
      await tester.tap(find.text('Réinitialiser'));
      await tester.pumpAndSettle();

      // Verify timer is reset to 2:00
      expect(find.text('2:00'), findsOneWidget);
      expect(find.text('Démarrer'), findsOneWidget);
    });

    // Test 4: Navigate to Guided Breathing page
    testWidgets('Test 4: Should navigate to guided breathing page', (tester) async {
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

      // Scroll down to find recommendations
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Navigate to guided breathing
      await tester.tap(find.text('Respiration guidée'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify guided breathing page is displayed
      expect(find.text('Respiration guidée'), findsOneWidget);
      expect(find.text('Exercice 4–4–6'), findsOneWidget);
      expect(find.text('Démarrer'), findsOneWidget);
    });

    // Test 5: Start breathing exercise
    testWidgets('Test 5: Should start breathing exercise', (tester) async {
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

      // Scroll and navigate to breathing
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Respiration guidée'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify initial phase
      expect(find.text('Inspirez doucement'), findsOneWidget);
      expect(find.text('4s'), findsOneWidget);

      // Start breathing exercise
      await tester.tap(find.text('Démarrer'));
      await tester.pump(const Duration(seconds: 2));

      // Verify button changes to Pause
      expect(find.text('Pause'), findsOneWidget);
    });

    // Test 6: Verify breathing page has all required elements
    testWidgets('Test 6: Should display all breathing page elements', (tester) async {
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

      // Scroll and navigate to breathing
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Respiration guidée'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify all required elements are present
      expect(find.text('Respiration guidée'), findsOneWidget);
      expect(find.text('Exercice 4–4–6'), findsOneWidget);
      expect(find.text('Conseils'), findsOneWidget);
      expect(find.text('Démarrer'), findsOneWidget);
      expect(find.text('Réinitialiser'), findsOneWidget);
      expect(find.byIcon(Icons.spa_rounded), findsOneWidget);
    });
  });
}

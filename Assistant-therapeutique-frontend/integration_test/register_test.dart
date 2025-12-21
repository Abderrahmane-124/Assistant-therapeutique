// Integration tests for the Register page with visual browser execution.
// These tests run in Chrome and you can see the UI interactions.
// Run with: flutter drive --driver=test_driver/integration_test.dart --target=integration_test/register_test.dart -d chrome

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moodmate/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  // Ignore known Flutter Web semantics exceptions
  binding.takeException();

  group('Register Page Tests', () {
    // Test 1: Champs vides - doit afficher une erreur
    testWidgets('Test 1: Should show error when fields are empty', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to register page
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      // Verify register page is displayed
      expect(find.text('Create an account'), findsOneWidget);

      // Tap sign up button without filling any fields
      final signUpButton = find.widgetWithText(ElevatedButton, 'Sign up');
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Verify error dialog appears
      expect(find.text('Erreur'), findsOneWidget);
      expect(find.text('Veuillez remplir tous les champs'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });

    // Test 2: Inscription valide avec données dynamiques (date/heure)
    testWidgets('Test 2: Should register successfully with valid data', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to register
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      // Generate dynamic data with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final dynamicEmail = 'testuser_$timestamp@test.com';
      final dynamicName = 'TestUser_$timestamp';

      // Fill form fields
      final nameField = find.widgetWithText(TextField, 'Your name');
      final emailField = find.widgetWithText(TextField, 'name@example.com');
      final passwordField = find.widgetWithText(TextField, 'Password');
      final confirmField = find.widgetWithText(TextField, 'Confirm password');

      await tester.enterText(nameField, dynamicName);
      await tester.pumpAndSettle();
      
      await tester.enterText(emailField, dynamicEmail);
      await tester.pumpAndSettle();
      
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();
      
      await tester.enterText(confirmField, 'password123');
      await tester.pumpAndSettle();

      // Verify data was entered correctly
      expect(find.text(dynamicName), findsOneWidget);

      // Tap sign up button
      final signUpButton = find.widgetWithText(ElevatedButton, 'Sign up');
      await tester.tap(signUpButton);
      
      // Use pump with duration instead of pumpAndSettle to avoid Flutter Web semantics issues
      await tester.pump(const Duration(seconds: 3));
      
      // Clear any Flutter Web semantics exceptions that may have occurred during navigation
      binding.takeException();
      
      await tester.pump(const Duration(seconds: 2));
      
      // Clear any remaining exceptions
      binding.takeException();

      // Verify successful registration - should navigate to login page
      // Check if we're on login page (Welcome back) or if registration form is gone
      final loginPageFound = find.text('Welcome back').evaluate().isNotEmpty;
      final registerPageGone = find.text('Create an account').evaluate().isEmpty;
      
      expect(loginPageFound || registerPageGone, isTrue, 
             reason: 'Should navigate away from register page after successful registration');
    });
  });
}

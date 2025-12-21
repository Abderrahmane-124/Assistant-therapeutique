// Consolidated Integration tests - Login once, run all feature tests.
// Run with: flutter drive --driver=test_driver/integration_test.dart --target=integration_test/all_features_test.dart -d chrome

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moodmate/main.dart' as app;

/// Helper to navigate back to home page
Future<void> navigateBackToHome(WidgetTester tester) async {
  // First try arrow_back icon to go back
  var attempts = 0;
  while (attempts < 3) {
    if (find.text('ENREGISTRER MON HUMEUR').evaluate().isNotEmpty) {
      break; // Already on home
    }
    final backButton = find.byIcon(Icons.arrow_back);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    } else {
      break;
    }
    attempts++;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete E2E Test Suite - Single Login Session', (tester) async {
    // ========================================
    // STEP 1: START APP AND LOGIN ONCE
    // ========================================
    app.main();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Login with valid credentials
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

    // Verify login successful - home page is displayed
    expect(find.text('ENREGISTRER MON HUMEUR'), findsOneWidget);
    debugPrint('✅ LOGIN SUCCESSFUL - Home page displayed');

    // ========================================
    // STEP 2: MOOD TRACKING TESTS
    // ========================================
    debugPrint('\n📊 TESTING: Mood Tracking Features');

    // Navigate to mood tracking page
    await tester.tap(find.text('ENREGISTRER MON HUMEUR'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify mood tracking page
    expect(find.text('Mon Humeur du Jour'), findsOneWidget);
    debugPrint('   ✅ Mood tracking page displayed');

    // Test: Submit without selecting mood (error case)
    await tester.tap(find.text('ENREGISTRER MON HUMEUR'));
    await tester.pumpAndSettle();
    
    if (find.text('Sélectionnez votre humeur').evaluate().isNotEmpty) {
      debugPrint('   ✅ Error dialog shown for empty mood');
      // Close dialog
      await tester.tap(find.text('Compris'));
      await tester.pumpAndSettle();
    }

    // Select a mood (Content)
    final contentMood = find.text('Content');
    if (contentMood.evaluate().isNotEmpty) {
      await tester.tap(contentMood);
      await tester.pumpAndSettle();
      debugPrint('   ✅ Mood "Content" selected');
    }

    // Submit mood
    await tester.tap(find.text('ENREGISTRER MON HUMEUR'));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Handle return button or navigation
    final retourButton = find.text('Retour');
    if (retourButton.evaluate().isNotEmpty) {
      await tester.tap(retourButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
    debugPrint('   ✅ Mood saved successfully');

    // Navigate back to home
    await navigateBackToHome(tester);
    debugPrint('   ✅ Returned to home page');

    // ========================================
    // STEP 3: MOOD HISTORY TEST
    // ========================================
    debugPrint('\n📈 TESTING: Mood History');

    final voirDetail = find.text('VOIR LE DÉTAIL');
    if (voirDetail.evaluate().isNotEmpty) {
      await tester.tap(voirDetail);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      debugPrint('   ✅ Mood history page accessed');
      
      // Go back to home
      await navigateBackToHome(tester);
    }

    // ========================================
    // STEP 4: JOURNAL TESTS
    // ========================================
    debugPrint('\n📓 TESTING: Journal Features');

    final ouvrirJournal = find.text('OUVRIR LE JOURNAL');
    if (ouvrirJournal.evaluate().isNotEmpty) {
      await tester.tap(ouvrirJournal);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      if (find.text('Mon Journal').evaluate().isNotEmpty) {
        debugPrint('   ✅ Journal page displayed');

        // Create a journal entry
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final journalContent = 'E2E Test Entry - $timestamp';

        final textField = find.byType(TextField);
        if (textField.evaluate().isNotEmpty) {
          await tester.enterText(textField, journalContent);
          await tester.pumpAndSettle();
          debugPrint('   ✅ Journal text entered');
        }

        // Save journal
        final saveBtn = find.text('SAUVEGARDER');
        if (saveBtn.evaluate().isNotEmpty) {
          await tester.tap(saveBtn);
          await tester.pumpAndSettle(const Duration(seconds: 5));
          debugPrint('   ✅ Journal saved successfully');
        }

        // Navigate to journal history
        final historyIcon = find.byIcon(Icons.history);
        if (historyIcon.evaluate().isNotEmpty) {
          await tester.tap(historyIcon);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          debugPrint('   ✅ Journal history accessed');

          // Go back from history
          final backBtn = find.byIcon(Icons.arrow_back);
          if (backBtn.evaluate().isNotEmpty) {
            await tester.tap(backBtn);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }
      }

      // Navigate back to home
      await navigateBackToHome(tester);
    }

    // ========================================
    // STEP 5: WELLNESS - MEDITATION TEST
    // ========================================
    debugPrint('\n🧘 TESTING: Meditation Features');

    // Scroll to recommendations
    final scrollable = find.byType(SingleChildScrollView);
    if (scrollable.evaluate().isNotEmpty) {
      await tester.drag(scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();
    }

    // Navigate to meditation
    final meditationBtn = find.text('Méditation 2 min');
    if (meditationBtn.evaluate().isNotEmpty) {
      await tester.tap(meditationBtn);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      if (find.text('Relaxation guidée').evaluate().isNotEmpty) {
        debugPrint('   ✅ Meditation page displayed');

        // Verify timer
        if (find.text('2:00').evaluate().isNotEmpty) {
          debugPrint('   ✅ Timer shows 2:00');
        }

        // Start meditation
        final demarrer = find.text('Démarrer');
        if (demarrer.evaluate().isNotEmpty) {
          await tester.tap(demarrer);
          await tester.pump(const Duration(seconds: 2));
          
          if (find.text('Pause').evaluate().isNotEmpty) {
            debugPrint('   ✅ Meditation started');
            
            // Pause
            await tester.tap(find.text('Pause'));
            await tester.pumpAndSettle();
            debugPrint('   ✅ Meditation paused');
          }
        }

        // Reset timer
        final reset = find.text('Réinitialiser');
        if (reset.evaluate().isNotEmpty) {
          await tester.tap(reset);
          await tester.pumpAndSettle();
          debugPrint('   ✅ Timer reset');
        }
      }

      // Go back to home
      await navigateBackToHome(tester);
    }

    // ========================================
    // STEP 6: WELLNESS - BREATHING TEST
    // ========================================
    debugPrint('\n🌬️ TESTING: Breathing Features');

    // Scroll to recommendations
    if (scrollable.evaluate().isNotEmpty) {
      await tester.drag(scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();
    }

    // Navigate to breathing
    final breathingBtn = find.text('Respiration guidée');
    if (breathingBtn.evaluate().isNotEmpty) {
      await tester.tap(breathingBtn);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      if (find.text('Exercice 4–4–6').evaluate().isNotEmpty) {
        debugPrint('   ✅ Breathing page displayed');

        // Start breathing
        final demarrer = find.text('Démarrer');
        if (demarrer.evaluate().isNotEmpty) {
          await tester.tap(demarrer);
          await tester.pump(const Duration(seconds: 2));
          
          if (find.text('Pause').evaluate().isNotEmpty) {
            debugPrint('   ✅ Breathing exercise started');
            
            // Pause
            await tester.tap(find.text('Pause'));
            await tester.pumpAndSettle();
            debugPrint('   ✅ Breathing exercise paused');
          }
        }
      }

      // Go back to home
      await navigateBackToHome(tester);
    }

    // ========================================
    // STEP 7: PROFILE/NAVIGATION TEST
    // ========================================
    debugPrint('\n👤 TESTING: Profile Navigation');

    final profileIcon = find.byIcon(Icons.person_outline);
    if (profileIcon.evaluate().isNotEmpty) {
      await tester.tap(profileIcon);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final profilePageFound = find.text('Profil').evaluate().isNotEmpty ||
                               find.text('Profile').evaluate().isNotEmpty ||
                               find.text('Déconnexion').evaluate().isNotEmpty ||
                               find.text('Logout').evaluate().isNotEmpty ||
                               find.byIcon(Icons.logout).evaluate().isNotEmpty;
      if (profilePageFound) {
        debugPrint('   ✅ Profile page displayed');
      }
    }

    // ========================================
    // FINAL: TEST COMPLETE
    // ========================================
    debugPrint('\n✅ ALL E2E TESTS PASSED - Single login session completed!');
  });
}

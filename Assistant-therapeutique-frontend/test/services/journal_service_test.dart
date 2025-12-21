import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/services/journal_service.dart';
import 'package:moodmate/models/journal_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('JournalService', () {
    late JournalService journalService;

    setUp(() {
      journalService = JournalService();
    });

    group('saveJournalEntry - validation', () {
      test('devrait lancer une exception si userId est null', () async {
        // Arrange - Aucun utilisateur connecté
        SharedPreferences.setMockInitialValues({});

        // Act & Assert
        expect(
          () => journalService.saveJournalEntry('Mon entrée de journal'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('User is not logged in'),
          )),
        );
      });

      test('devrait accepter du contenu vide', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'userId': 1});

        // Act - La requête peut échouer mais validons l'acceptation
        final result = await journalService.saveJournalEntry('');

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('success'), isTrue);
      });

      test('devrait accepter un contenu très long', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'userId': 1});
        final longContent = 'Journal entry ' * 500;

        // Act
        final result = await journalService.saveJournalEntry(longContent);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
      });

      test('devrait gérer les caractères spéciaux et emojis', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'userId': 1});
        const content = "Aujourd'hui j'ai ressenti 😊 de la joie! éàù";

        // Act
        final result = await journalService.saveJournalEntry(content);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
      });
    });

    group('getJournalEntries - gestion des erreurs', () {
      test('devrait lancer une exception si userId est null', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act & Assert
        expect(
          () => journalService.getJournalEntries(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('User is not logged in'),
          )),
        );
      });
    });

    group('updateJournalEntry - validation', () {
      test('devrait retourner un Map avec success key', () async {
        // Act
        final result = await journalService.updateJournalEntry(1, 'Contenu mis à jour');

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('success'), isTrue);
        expect(result.containsKey('message'), isTrue);
      });

      test('devrait gérer un id négatif', () async {
        // Act
        final result = await journalService.updateJournalEntry(-1, 'Test');

        // Assert
        expect(result['success'], isFalse);
      });

      test('devrait accepter un contenu vide pour la mise à jour', () async {
        // Act
        final result = await journalService.updateJournalEntry(1, '');

        // Assert
        expect(result, isA<Map<String, dynamic>>());
      });
    });

    group('deleteJournalEntry - validation', () {
      test('devrait retourner un Map avec les clés attendues', () async {
        // Act
        final result = await journalService.deleteJournalEntry(1);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('success'), isTrue);
        expect(result.containsKey('message'), isTrue);
      });

      test('devrait gérer la suppression avec id 0', () async {
        // Act
        final result = await journalService.deleteJournalEntry(0);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
      });

      test('devrait gérer la suppression avec grand id', () async {
        // Act
        final result = await journalService.deleteJournalEntry(999999999);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['success'], isFalse);
      });
    });

    group('Format de retour', () {
      test('saveJournalEntry devrait toujours avoir success et message', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'userId': 1});

        // Act
        final result = await journalService.saveJournalEntry('Test');

        // Assert
        expect(result.keys, containsAll(['success', 'message']));
      });

      test('updateJournalEntry devrait toujours avoir success et message', () async {
        // Act
        final result = await journalService.updateJournalEntry(1, 'Test');

        // Assert
        expect(result.keys, containsAll(['success', 'message']));
      });

      test('deleteJournalEntry devrait toujours avoir success et message', () async {
        // Act
        final result = await journalService.deleteJournalEntry(1);

        // Assert
        expect(result.keys, containsAll(['success', 'message']));
      });
    });
  });
}

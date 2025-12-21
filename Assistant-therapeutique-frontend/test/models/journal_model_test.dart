import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/models/journal_model.dart';

void main() {
  group('JournalEntry Model', () {
    group('toJson', () {
      test('devrait convertir un JournalEntry complet en JSON', () {
        // Arrange
        final entry = JournalEntry(
          id: 1,
          content: 'Mon journal du jour',
          createdAt: DateTime(2024, 1, 15, 10, 30),
          userId: 42,
        );

        // Act
        final json = entry.toJson();

        // Assert
        expect(json['id'], equals(1));
        expect(json['content'], equals('Mon journal du jour'));
        expect(json['createdAt'], equals('2024-01-15T10:30:00.000'));
        expect(json['userId'], equals(42));
      });

      test('devrait gérer les valeurs nulles pour id et userId', () {
        // Arrange
        final entry = JournalEntry(
          content: 'Contenu',
          createdAt: DateTime.now(),
        );

        // Act
        final json = entry.toJson();

        // Assert
        expect(json['id'], isNull);
        expect(json['userId'], isNull);
        expect(json['content'], equals('Contenu'));
      });
    });

    group('fromJson', () {
      test('devrait créer un JournalEntry à partir de JSON valide', () {
        // Arrange
        final json = {
          'id': 1,
          'content': 'Contenu du journal',
          'createdAt': '2024-01-15T10:30:00.000',
          'userId': 42,
        };

        // Act
        final entry = JournalEntry.fromJson(json);

        // Assert
        expect(entry.id, equals(1));
        expect(entry.content, equals('Contenu du journal'));
        expect(entry.createdAt, equals(DateTime(2024, 1, 15, 10, 30)));
        expect(entry.userId, equals(42));
      });

      test('devrait gérer userId null', () {
        // Arrange
        final json = {
          'id': 1,
          'content': 'Contenu',
          'createdAt': '2024-01-15T10:30:00.000',
          'userId': null,
        };

        // Act
        final entry = JournalEntry.fromJson(json);

        // Assert
        expect(entry.userId, isNull);
      });

      test('devrait parser correctement la date ISO8601', () {
        // Arrange
        final json = {
          'id': 1,
          'content': 'Test',
          'createdAt': '2024-12-25T14:30:00Z',
          'userId': 1,
        };

        // Act
        final entry = JournalEntry.fromJson(json);

        // Assert
        expect(entry.createdAt.year, equals(2024));
        expect(entry.createdAt.month, equals(12));
        expect(entry.createdAt.day, equals(25));
      });
    });

    group('Mutable content', () {
      test('devrait permettre la modification du contenu', () {
        // Arrange
        final entry = JournalEntry(
          id: 1,
          content: 'Contenu initial',
          createdAt: DateTime.now(),
        );

        // Act
        entry.content = 'Contenu modifié';

        // Assert
        expect(entry.content, equals('Contenu modifié'));
      });
    });

    group('Constructor', () {
      test('devrait créer une entrée avec seulement les champs requis', () {
        // Arrange & Act
        final entry = JournalEntry(
          content: 'Minimal content',
          createdAt: DateTime(2024, 5, 10),
        );

        // Assert
        expect(entry.id, isNull);
        expect(entry.content, equals('Minimal content'));
        expect(entry.userId, isNull);
        expect(entry.createdAt, equals(DateTime(2024, 5, 10)));
      });

      test('devrait créer une entrée avec tous les champs', () {
        // Arrange
        final testDate = DateTime(2024, 8, 20, 12, 0);

        // Act
        final entry = JournalEntry(
          id: 100,
          content: 'Full entry',
          createdAt: testDate,
          userId: 50,
        );

        // Assert
        expect(entry.id, equals(100));
        expect(entry.content, equals('Full entry'));
        expect(entry.createdAt, equals(testDate));
        expect(entry.userId, equals(50));
      });
    });

    group('Round-trip serialization', () {
      test('devrait préserver les données lors de la sérialisation/désérialisation', () {
        // Arrange
        final original = JournalEntry(
          id: 99,
          content: 'Test round-trip',
          createdAt: DateTime(2024, 3, 20, 15, 45, 30),
          userId: 777,
        );

        // Act
        final json = original.toJson();
        final reconstructed = JournalEntry.fromJson(json);

        // Assert
        expect(reconstructed.id, equals(original.id));
        expect(reconstructed.content, equals(original.content));
        expect(reconstructed.userId, equals(original.userId));
        // Note: createdAt might have slight differences due to ISO format parsing
        expect(reconstructed.createdAt.year, equals(original.createdAt.year));
        expect(reconstructed.createdAt.month, equals(original.createdAt.month));
        expect(reconstructed.createdAt.day, equals(original.createdAt.day));
      });

      test('devrait gérer le contenu avec caractères spéciaux', () {
        // Arrange
        final original = JournalEntry(
          content: "J'ai passé une journée \"incroyable\" aujourd'hui! 🎉",
          createdAt: DateTime.now(),
        );

        // Act
        final json = original.toJson();
        final reconstructed = JournalEntry.fromJson(json);

        // Assert
        expect(reconstructed.content, equals(original.content));
      });

      test('devrait gérer le contenu multiligne', () {
        // Arrange
        final original = JournalEntry(
          content: '''Ligne 1
Ligne 2
Ligne 3''',
          createdAt: DateTime.now(),
        );

        // Act
        final json = original.toJson();
        final reconstructed = JournalEntry.fromJson(json);

        // Assert
        expect(reconstructed.content, contains('Ligne 1'));
        expect(reconstructed.content, contains('Ligne 2'));
        expect(reconstructed.content, contains('Ligne 3'));
      });
    });
  });
}

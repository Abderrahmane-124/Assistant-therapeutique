import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/models/mood_model.dart';

void main() {
  group('Mood Model', () {
    group('toJson', () {
      test('devrait convertir un Mood complet en JSON', () {
        // Arrange
        final mood = Mood(
          id: 1,
          mood: 'happy',
          createdAt: DateTime(2024, 1, 15, 10, 30),
          userId: 42,
        );

        // Act
        final json = mood.toJson();

        // Assert
        expect(json['id'], equals(1));
        expect(json['mood'], equals('happy'));
        expect(json['createdAt'], equals('2024-01-15T10:30:00.000'));
        expect(json['user'], isA<Map<String, dynamic>>());
        expect(json['user']['id'], equals(42));
      });

      test('devrait gérer les valeurs nulles pour id', () {
        // Arrange
        final mood = Mood(
          mood: 'sad',
          userId: 1,
        );

        // Act
        final json = mood.toJson();

        // Assert
        expect(json['id'], isNull);
        expect(json['createdAt'], isNull);
      });

      test('devrait convertir correctement createdAt en ISO8601', () {
        // Arrange
        final testDate = DateTime(2024, 12, 25, 14, 30, 45);
        final mood = Mood(
          mood: 'excited',
          createdAt: testDate,
          userId: 5,
        );

        // Act
        final json = mood.toJson();

        // Assert
        expect(json['createdAt'], equals(testDate.toIso8601String()));
      });
    });

    group('fromJson', () {
      test('devrait créer un Mood à partir de JSON valide', () {
        // Arrange
        final json = {
          'id': 1,
          'mood': 'anxious',
          'createdAt': '2024-01-15T10:30:00.000',
          'user': {'id': 42},
        };

        // Act
        final mood = Mood.fromJson(json);

        // Assert
        expect(mood.id, equals(1));
        expect(mood.mood, equals('anxious'));
        expect(mood.createdAt, equals(DateTime(2024, 1, 15, 10, 30)));
        expect(mood.userId, equals(42));
      });

      test('devrait gérer createdAt null', () {
        // Arrange
        final json = {
          'id': 1,
          'mood': 'neutral',
          'createdAt': null,
          'user': {'id': 10},
        };

        // Act
        final mood = Mood.fromJson(json);

        // Assert
        expect(mood.id, equals(1));
        expect(mood.createdAt, isNull);
        expect(mood.userId, equals(10));
      });

      test('devrait parser différents formats de date ISO8601', () {
        // Arrange
        final json = {
          'id': 1,
          'mood': 'happy',
          'createdAt': '2024-06-15T08:00:00Z',
          'user': {'id': 1},
        };

        // Act
        final mood = Mood.fromJson(json);

        // Assert
        expect(mood.createdAt, isNotNull);
        expect(mood.createdAt!.year, equals(2024));
        expect(mood.createdAt!.month, equals(6));
        expect(mood.createdAt!.day, equals(15));
      });
    });

    group('Equality and properties', () {
      test('devrait avoir les bonnes propriétés avec constructeur', () {
        // Arrange & Act
        final mood = Mood(
          id: 5,
          mood: 'calm',
          createdAt: DateTime.now(),
          userId: 100,
        );

        // Assert
        expect(mood.id, equals(5));
        expect(mood.mood, equals('calm'));
        expect(mood.userId, equals(100));
      });

      test('devrait permettre différentes valeurs de mood', () {
        // Arrange
        final moodValues = ['happy', 'sad', 'anxious', 'calm', 'excited', 'angry'];

        for (final moodValue in moodValues) {
          // Act
          final mood = Mood(mood: moodValue, userId: 1);

          // Assert
          expect(mood.mood, equals(moodValue));
        }
      });
    });

    group('Round-trip serialization', () {
      test('devrait préserver les données lors de la sérialisation/désérialisation', () {
        // Arrange
        final originalMood = Mood(
          id: 99,
          mood: 'happy',
          createdAt: DateTime(2024, 3, 20, 15, 45, 30),
          userId: 777,
        );

        // Act - Simulate sending to backend and receiving back
        final json = originalMood.toJson();
        // Simulate backend response format
        final backendJson = {
          'id': json['id'],
          'mood': json['mood'],
          'createdAt': json['createdAt'],
          'user': json['user'],
        };
        final reconstructedMood = Mood.fromJson(backendJson);

        // Assert
        expect(reconstructedMood.id, equals(originalMood.id));
        expect(reconstructedMood.mood, equals(originalMood.mood));
        expect(reconstructedMood.userId, equals(originalMood.userId));
      });
    });
  });
}

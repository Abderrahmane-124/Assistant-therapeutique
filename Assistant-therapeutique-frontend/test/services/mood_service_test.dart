import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/services/mood_service.dart';
import 'package:moodmate/models/mood_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('MoodService', () {
    late MoodService moodService;

    setUp(() {
      moodService = MoodService();
    });

    group('getMoods - gestion des erreurs', () {
      test('devrait lancer une exception si userId est null', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act & Assert
        expect(
          () => moodService.getMoods(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('User is not logged in'),
          )),
        );
      });
    });

    group('saveMood - validation', () {
      test('devrait retourner un Map avec success key', () async {
        // Arrange
        final mood = Mood(
          userId: 1,
          mood: 'happy',
          createdAt: DateTime.now(),
        );

        // Act
        final result = await moodService.saveMood(mood);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('success'), isTrue);
        expect(result.containsKey('message'), isTrue);
      });

      test('devrait accepter différents types de mood', () async {
        // Test pour différents moods
        final moods = ['happy', 'sad', 'anxious', 'neutral', 'excited'];
        
        for (final moodType in moods) {
          final mood = Mood(
            userId: 1,
            mood: moodType,
            createdAt: DateTime.now(),
          );

          final result = await moodService.saveMood(mood);

          expect(result, isA<Map<String, dynamic>>());
        }
      });

      test('devrait gérer un mood avec createdAt null', () async {
        // Arrange
        final mood = Mood(
          userId: 1,
          mood: 'happy',
        );

        // Act
        final result = await moodService.saveMood(mood);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
      });
    });

    group('updateMood - validation', () {
      test('devrait retourner erreur si mood.id est null', () async {
        // Arrange
        final mood = Mood(
          userId: 1,
          mood: 'happy',
          createdAt: DateTime.now(),
        );

        // Act
        final result = await moodService.updateMood(mood);

        // Assert
        expect(result['success'], isFalse);
        expect(result['message'], contains('Mood ID must be provided'));
      });

      test('devrait retourner un Map valide si mood.id est fourni', () async {
        // Arrange
        final mood = Mood(
          id: 1,
          userId: 1,
          mood: 'sad',
          createdAt: DateTime.now(),
        );

        // Act
        final result = await moodService.updateMood(mood);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('success'), isTrue);
      });

      test('devrait accepter mise à jour du type de mood', () async {
        // Arrange
        final mood = Mood(
          id: 1,
          userId: 1,
          mood: 'excited',
          createdAt: DateTime.now(),
        );

        // Act
        final result = await moodService.updateMood(mood);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
      });
    });

    group('deleteMood - validation', () {
      test('devrait retourner un Map avec les clés success et message', () async {
        // Act
        final result = await moodService.deleteMood(1);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('success'), isTrue);
        expect(result.containsKey('message'), isTrue);
      });

      test('devrait gérer un moodId valide', () async {
        // Act
        final result = await moodService.deleteMood(123);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
      });

      test('devrait gérer un grand moodId', () async {
        // Act
        final result = await moodService.deleteMood(999999999);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['success'], isFalse);
      });
    });

    group('Création de Mood - modèle', () {
      test('devrait créer un Mood valide avec tous les champs', () {
        // Arrange
        final now = DateTime.now();

        // Act
        final mood = Mood(
          id: 1,
          userId: 2,
          mood: 'happy',
          createdAt: now,
        );

        // Assert
        expect(mood.id, equals(1));
        expect(mood.userId, equals(2));
        expect(mood.mood, equals('happy'));
        expect(mood.createdAt, equals(now));
      });

      test('devrait créer un Mood sans id (nouveau mood)', () {
        // Act
        final mood = Mood(
          userId: 1,
          mood: 'neutral',
          createdAt: DateTime.now(),
        );

        // Assert
        expect(mood.id, isNull);
      });

      test('devrait accepter différents types de mood valides', () {
        // Arrange & Act
        final moodTypes = ['happy', 'sad', 'anxious', 'neutral', 'excited', 'calm'];
        
        for (final moodType in moodTypes) {
          final mood = Mood(
            userId: 1,
            mood: moodType,
            createdAt: DateTime.now(),
          );
          expect(mood.mood, equals(moodType));
        }
      });
    });

    group('Mood toJson', () {
      test('devrait convertir correctement en JSON', () {
        // Arrange
        final now = DateTime.now();
        final mood = Mood(
          id: 1,
          userId: 2,
          mood: 'happy',
          createdAt: now,
        );

        // Act
        final json = mood.toJson();

        // Assert
        expect(json['id'], equals(1));
        expect(json['mood'], equals('happy'));
        expect(json['user']['id'], equals(2));
        expect(json['createdAt'], equals(now.toIso8601String()));
      });

      test('devrait gérer createdAt null', () {
        // Arrange
        final mood = Mood(
          userId: 1,
          mood: 'sad',
        );

        // Act
        final json = mood.toJson();

        // Assert
        expect(json['createdAt'], isNull);
      });
    });

    group('Mood fromJson', () {
      test('devrait créer un Mood à partir de JSON', () {
        // Arrange
        final json = {
          'id': 1,
          'mood': 'happy',
          'createdAt': '2024-01-15T10:30:00.000',
          'user': {'id': 2},
        };

        // Act
        final mood = Mood.fromJson(json);

        // Assert
        expect(mood.id, equals(1));
        expect(mood.mood, equals('happy'));
        expect(mood.userId, equals(2));
        expect(mood.createdAt, isNotNull);
      });

      test('devrait gérer createdAt null dans JSON', () {
        // Arrange
        final json = {
          'id': 1,
          'mood': 'neutral',
          'createdAt': null,
          'user': {'id': 1},
        };

        // Act
        final mood = Mood.fromJson(json);

        // Assert
        expect(mood.createdAt, isNull);
      });
    });

    group('Round-trip serialization', () {
      test('devrait préserver les données lors de la sérialisation/désérialisation', () {
        // Arrange
        final original = Mood(
          id: 5,
          userId: 10,
          mood: 'excited',
          createdAt: DateTime(2024, 1, 15, 10, 30),
        );

        // Act
        final json = original.toJson();
        // Note: fromJson expects 'user' key, which toJson provides
        final reconstructed = Mood.fromJson(json);

        // Assert
        expect(reconstructed.id, equals(original.id));
        expect(reconstructed.userId, equals(original.userId));
        expect(reconstructed.mood, equals(original.mood));
      });
    });
  });
}

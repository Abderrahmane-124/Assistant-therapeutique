import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/features/auth/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
      SharedPreferences.setMockInitialValues({});
    });

    group('getUserId', () {
      test('devrait retourner null si aucun userId stocké', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await AuthService.getUserId();

        // Assert
        expect(result, isNull);
      });

      test('devrait retourner le userId stocké', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'userId': 42});

        // Act
        final result = await AuthService.getUserId();

        // Assert
        expect(result, equals(42));
      });

      test('devrait retourner un grand userId', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'userId': 999999});

        // Act
        final result = await AuthService.getUserId();

        // Assert
        expect(result, equals(999999));
      });
    });

    group('clearUserId', () {
      test('devrait supprimer le userId stocké', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'userId': 1});

        // Act
        await AuthService.clearUserId();
        final result = await AuthService.getUserId();

        // Assert
        expect(result, isNull);
      });

      test('devrait fonctionner même si pas de userId', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act & Assert - Ne doit pas lancer d'erreur
        await AuthService.clearUserId();
        final result = await AuthService.getUserId();
        expect(result, isNull);
      });
    });

    group('login - validation', () {
      test('devrait retourner un Map avec success et message', () async {
        // Act - La requête échouera mais validons le format
        final result = await authService.login('testuser', 'password123');

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('success'), isTrue);
      });

      test('devrait gérer un username vide', () async {
        // Act
        final result = await authService.login('', 'password');

        // Assert
        expect(result['success'], isFalse);
      });

      test('devrait gérer un password vide', () async {
        // Act
        final result = await authService.login('user', '');

        // Assert
        expect(result['success'], isFalse);
      });

      test('devrait gérer les caractères spéciaux', () async {
        // Act
        final result = await authService.login("user@test.com", "P@ss\$word!");

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['success'], isFalse); // Server not running
      });

      test('devrait retourner message erreur connexion serveur', () async {
        // Act
        final result = await authService.login('user', 'pass');

        // Assert
        expect(result['success'], isFalse);
        expect(result['message'], contains('serveur'));
      });
    });

    group('register - validation', () {
      test('devrait retourner un Map avec success', () async {
        // Act
        final result = await authService.register('newuser', 'password123', 'test@email.com');

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('success'), isTrue);
      });

      test('devrait gérer un email invalide', () async {
        // Act
        final result = await authService.register('user', 'pass', 'invalid-email');

        // Assert
        expect(result, isA<Map<String, dynamic>>());
      });

      test('devrait gérer un username vide', () async {
        // Act
        final result = await authService.register('', 'password', 'email@test.com');

        // Assert
        expect(result['success'], isFalse);
      });

      test('devrait gérer un password vide', () async {
        // Act
        final result = await authService.register('user', '', 'email@test.com');

        // Assert
        expect(result['success'], isFalse);
      });

      test('devrait retourner message erreur connexion serveur', () async {
        // Act
        final result = await authService.register('user', 'pass', 'email@test.com');

        // Assert
        expect(result['success'], isFalse);
        expect(result['message'], contains('serveur'));
      });
    });

    group('getProfile - validation', () {
      test('devrait retourner erreur si non connecté', () async {
        // Arrange - Pas de userId
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await authService.getProfile();

        // Assert
        expect(result['success'], isFalse);
        expect(result['message'], equals('Utilisateur non connecté'));
      });

      test('devrait retourner un Map avec les clés attendues si connecté', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'userId': 1});

        // Act
        final result = await authService.getProfile();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('success'), isTrue);
      });

      test('devrait gérer erreur connexion si userId présent', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'userId': 999});

        // Act
        final result = await authService.getProfile();

        // Assert
        expect(result['success'], isFalse);
        expect(result['message'], isNotNull);
      });
    });

    group('updateUserProfile - validation', () {
      test('devrait retourner un Map avec success', () async {
        // Act
        final result = await authService.updateUserProfile(1, {'username': 'newname'});

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('success'), isTrue);
      });

      test('devrait gérer des données vides', () async {
        // Act
        final result = await authService.updateUserProfile(1, {});

        // Assert
        expect(result, isA<Map<String, dynamic>>());
      });

      test('devrait gérer un userId invalide', () async {
        // Act
        final result = await authService.updateUserProfile(-1, {'name': 'test'});

        // Assert
        expect(result['success'], isFalse);
      });

      test('devrait retourner message erreur connexion', () async {
        // Act
        final result = await authService.updateUserProfile(1, {'email': 'new@email.com'});

        // Assert
        expect(result['success'], isFalse);
        expect(result['message'], isNotNull);
      });

      test('devrait gérer des données complexes', () async {
        // Act
        final result = await authService.updateUserProfile(1, {
          'username': 'newuser',
          'email': 'new@email.com',
          'bio': 'Ma nouvelle bio',
        });

        // Assert
        expect(result, isA<Map<String, dynamic>>());
      });
    });

    group('getStats - validation', () {
      test('devrait retourner erreur si non connecté', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await authService.getStats();

        // Assert
        expect(result['success'], isFalse);
        expect(result['message'], equals('Utilisateur non connecté'));
      });

      test('devrait retourner un Map si connecté', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'userId': 1});

        // Act
        final result = await authService.getStats();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('success'), isTrue);
      });

      test('devrait gérer erreur connexion si userId présent', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'userId': 123});

        // Act
        final result = await authService.getStats();

        // Assert
        expect(result['success'], isFalse);
        expect(result['message'], isNotNull);
      });
    });

    group('Scénarios complets', () {
      test('getUserId puis clearUserId devrait fonctionner', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'userId': 5});

        // Act
        final before = await AuthService.getUserId();
        await AuthService.clearUserId();
        final after = await AuthService.getUserId();

        // Assert
        expect(before, equals(5));
        expect(after, isNull);
      });

      test('getProfile après clearUserId devrait échouer', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'userId': 1});
        await AuthService.clearUserId();

        // Act
        final result = await authService.getProfile();

        // Assert
        expect(result['success'], isFalse);
        expect(result['message'], equals('Utilisateur non connecté'));
      });

      test('getStats après clearUserId devrait échouer', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'userId': 1});
        await AuthService.clearUserId();

        // Act
        final result = await authService.getStats();

        // Assert
        expect(result['success'], isFalse);
        expect(result['message'], equals('Utilisateur non connecté'));
      });
    });
  });
}

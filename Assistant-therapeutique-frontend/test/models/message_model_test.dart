import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/models/message_model.dart';

void main() {
  group('Message Model', () {
    group('fromJson - Basic parsing', () {
      test('devrait créer un Message à partir de JSON complet', () {
        // Arrange
        final json = {
          'id': 1,
          'content': 'Bonjour, comment allez-vous?',
          'senderId': 0,
          'createdAt': '2024-01-15T10:30:00.000',
          'conversationId': 5,
        };

        // Act
        final message = Message.fromJson(json);

        // Assert
        expect(message.id, equals(1));
        expect(message.content, equals('Bonjour, comment allez-vous?'));
        expect(message.senderId, equals(0));
        expect(message.conversationId, equals(5));
      });

      test('devrait gérer content null en retournant chaîne vide', () {
        // Arrange
        final json = {
          'id': 1,
          'content': null,
          'senderId': 0,
          'createdAt': '2024-01-15T10:30:00.000',
          'conversationId': 1,
        };

        // Act
        final message = Message.fromJson(json);

        // Assert
        expect(message.content, equals(''));
      });
    });

    group('fromJson - SenderId parsing', () {
      test('devrait parser senderId depuis un objet sender imbriqué', () {
        // Arrange
        final json = {
          'id': 1,
          'content': 'Test',
          'sender': {'id': 42},
          'createdAt': '2024-01-15T10:30:00.000',
          'conversationId': 1,
        };

        // Act
        final message = Message.fromJson(json);

        // Assert
        expect(message.senderId, equals(42));
      });

      test('devrait convertir "assistant" en senderId 1', () {
        // Arrange
        final json = {
          'id': 1,
          'content': 'Test',
          'sender': 'assistant',
          'createdAt': '2024-01-15T10:30:00.000',
          'conversationId': 1,
        };

        // Act
        final message = Message.fromJson(json);

        // Assert
        expect(message.senderId, equals(1));
      });

      test('devrait convertir "user" en senderId 0', () {
        // Arrange
        final json = {
          'id': 1,
          'content': 'Test',
          'sender': 'user',
          'createdAt': '2024-01-15T10:30:00.000',
          'conversationId': 1,
        };

        // Act
        final message = Message.fromJson(json);

        // Assert
        expect(message.senderId, equals(0));
      });

      test('devrait parser senderId depuis une chaîne numérique', () {
        // Arrange
        final json = {
          'id': 1,
          'content': 'Test',
          'senderId': '5',
          'createdAt': '2024-01-15T10:30:00.000',
          'conversationId': 1,
        };

        // Act
        final message = Message.fromJson(json);

        // Assert
        expect(message.senderId, equals(5));
      });

      test('devrait retourner 0 pour senderId null', () {
        // Arrange
        final json = {
          'id': 1,
          'content': 'Test',
          'senderId': null,
          'createdAt': '2024-01-15T10:30:00.000',
          'conversationId': 1,
        };

        // Act
        final message = Message.fromJson(json);

        // Assert
        expect(message.senderId, equals(0));
      });
    });

    group('fromJson - Timestamp parsing', () {
      test('devrait parser timestamp depuis createdAt', () {
        // Arrange
        final json = {
          'id': 1,
          'content': 'Test',
          'senderId': 0,
          'createdAt': '2024-06-15T14:30:00.000',
          'conversationId': 1,
        };

        // Act
        final message = Message.fromJson(json);

        // Assert
        expect(message.timestamp.year, equals(2024));
        expect(message.timestamp.month, equals(6));
        expect(message.timestamp.day, equals(15));
      });

      test('devrait parser timestamp depuis champ timestamp alternatif', () {
        // Arrange
        final json = {
          'id': 1,
          'content': 'Test',
          'senderId': 0,
          'timestamp': '2024-06-15T14:30:00.000',
          'conversationId': 1,
        };

        // Act
        final message = Message.fromJson(json);

        // Assert
        expect(message.timestamp.year, equals(2024));
      });

      test('devrait parser timestamp depuis epoch milliseconds', () {
        // Arrange
        final epochMs = DateTime(2024, 1, 15, 10, 30).millisecondsSinceEpoch;
        final json = {
          'id': 1,
          'content': 'Test',
          'senderId': 0,
          'createdAt': epochMs,
          'conversationId': 1,
        };

        // Act
        final message = Message.fromJson(json);

        // Assert
        expect(message.timestamp.year, equals(2024));
        expect(message.timestamp.month, equals(1));
        expect(message.timestamp.day, equals(15));
      });

      test('devrait utiliser DateTime.now() pour timestamp null', () {
        // Arrange
        final beforeTest = DateTime.now();
        final json = {
          'id': 1,
          'content': 'Test',
          'senderId': 0,
          'createdAt': null,
          'conversationId': 1,
        };

        // Act
        final message = Message.fromJson(json);
        final afterTest = DateTime.now();

        // Assert
        expect(message.timestamp.isAfter(beforeTest.subtract(const Duration(seconds: 1))), isTrue);
        expect(message.timestamp.isBefore(afterTest.add(const Duration(seconds: 1))), isTrue);
      });
    });

    group('fromJson - ConversationId parsing', () {
      test('devrait parser conversationId depuis un objet imbriqué', () {
        // Arrange
        final json = {
          'id': 1,
          'content': 'Test',
          'senderId': 0,
          'createdAt': '2024-01-15T10:30:00.000',
          'conversation': {'id': 99},
        };

        // Act
        final message = Message.fromJson(json);

        // Assert
        expect(message.conversationId, equals(99));
      });

      test('devrait parser conversationId depuis une chaîne', () {
        // Arrange
        final json = {
          'id': 1,
          'content': 'Test',
          'senderId': 0,
          'createdAt': '2024-01-15T10:30:00.000',
          'conversationId': '42',
        };

        // Act
        final message = Message.fromJson(json);

        // Assert
        expect(message.conversationId, equals(42));
      });
    });

    group('toJson', () {
      test('devrait convertir un Message en JSON', () {
        // Arrange
        final message = Message(
          id: 1,
          content: 'Test message',
          senderId: 0,
          timestamp: DateTime(2024, 1, 15, 10, 30),
          conversationId: 5,
        );

        // Act
        final json = message.toJson();

        // Assert
        expect(json['id'], equals(1));
        expect(json['content'], equals('Test message'));
        expect(json['senderId'], equals(0));
        expect(json['createdAt'], equals('2024-01-15T10:30:00.000'));
        expect(json['conversationId'], equals(5));
      });
    });

    group('Helper methods', () {
      test('isUser devrait retourner true pour senderId 0', () {
        // Arrange
        final message = Message(
          content: 'User message',
          senderId: 0,
          timestamp: DateTime.now(),
          conversationId: 1,
        );

        // Assert
        expect(message.isUser, isTrue);
        expect(message.isAssistant, isFalse);
      });

      test('isAssistant devrait retourner true pour senderId 1', () {
        // Arrange
        final message = Message(
          content: 'Assistant message',
          senderId: 1,
          timestamp: DateTime.now(),
          conversationId: 1,
        );

        // Assert
        expect(message.isAssistant, isTrue);
        expect(message.isUser, isFalse);
      });
    });

    group('copyWith', () {
      test('devrait créer une copie avec des valeurs modifiées', () {
        // Arrange
        final original = Message(
          id: 1,
          content: 'Original',
          senderId: 0,
          timestamp: DateTime(2024, 1, 15),
          conversationId: 1,
        );

        // Act
        final copy = original.copyWith(
          content: 'Modified',
          senderId: 1,
        );

        // Assert
        expect(copy.id, equals(original.id));
        expect(copy.content, equals('Modified'));
        expect(copy.senderId, equals(1));
        expect(copy.timestamp, equals(original.timestamp));
        expect(copy.conversationId, equals(original.conversationId));
      });

      test('devrait préserver les valeurs non modifiées', () {
        // Arrange
        final original = Message(
          id: 99,
          content: 'Test',
          senderId: 0,
          timestamp: DateTime(2024, 6, 15),
          conversationId: 77,
        );

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy.id, equals(original.id));
        expect(copy.content, equals(original.content));
        expect(copy.senderId, equals(original.senderId));
        expect(copy.timestamp, equals(original.timestamp));
        expect(copy.conversationId, equals(original.conversationId));
      });
    });

    group('Round-trip serialization', () {
      test('devrait préserver les données lors de la sérialisation/désérialisation', () {
        // Arrange
        final original = Message(
          id: 42,
          content: 'Test round-trip message',
          senderId: 0,
          timestamp: DateTime(2024, 3, 20, 15, 45),
          conversationId: 10,
        );

        // Act
        final json = original.toJson();
        final reconstructed = Message.fromJson(json);

        // Assert
        expect(reconstructed.id, equals(original.id));
        expect(reconstructed.content, equals(original.content));
        expect(reconstructed.senderId, equals(original.senderId));
        expect(reconstructed.conversationId, equals(original.conversationId));
      });
    });
  });
}

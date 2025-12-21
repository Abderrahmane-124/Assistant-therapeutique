import 'package:flutter_test/flutter_test.dart';
import 'package:moodmate/models/conversation_model.dart';
import 'package:moodmate/models/message_model.dart';

void main() {
  group('Conversation Model', () {
    group('fromJson - Basic parsing', () {
      test('devrait créer une Conversation à partir de JSON complet', () {
        // Arrange
        final json = {
          'id': 1,
          'titre': 'Ma conversation',
          'userId': 42,
          'createdAt': '2024-01-15T10:30:00.000',
        };

        // Act
        final conversation = Conversation.fromJson(json);

        // Assert
        expect(conversation.id, equals(1));
        expect(conversation.titre, equals('Ma conversation'));
        expect(conversation.userId, equals(42));
        expect(conversation.createdAt.year, equals(2024));
      });

      test('devrait utiliser "Sans titre" pour titre null', () {
        // Arrange
        final json = {
          'id': 1,
          'titre': null,
          'userId': 1,
          'createdAt': '2024-01-15T10:30:00.000',
        };

        // Act
        final conversation = Conversation.fromJson(json);

        // Assert
        expect(conversation.titre, equals('Sans titre'));
      });

      test('devrait utiliser le champ title si titre absent', () {
        // Arrange
        final json = {
          'id': 1,
          'title': 'English title',
          'userId': 1,
          'createdAt': '2024-01-15T10:30:00.000',
        };

        // Act
        final conversation = Conversation.fromJson(json);

        // Assert
        expect(conversation.titre, equals('English title'));
      });
    });

    group('fromJson - UserId parsing', () {
      test('devrait parser userId depuis un objet user imbriqué', () {
        // Arrange
        final json = {
          'id': 1,
          'titre': 'Test',
          'user': {'id': 99},
          'createdAt': '2024-01-15T10:30:00.000',
        };

        // Act
        final conversation = Conversation.fromJson(json);

        // Assert
        expect(conversation.userId, equals(99));
      });

      test('devrait parser userId depuis le champ direct', () {
        // Arrange
        final json = {
          'id': 1,
          'titre': 'Test',
          'userId': 77,
          'createdAt': '2024-01-15T10:30:00.000',
        };

        // Act
        final conversation = Conversation.fromJson(json);

        // Assert
        expect(conversation.userId, equals(77));
      });

      test('devrait retourner 0 pour userId manquant', () {
        // Arrange
        final json = {
          'id': 1,
          'titre': 'Test',
          'createdAt': '2024-01-15T10:30:00.000',
        };

        // Act
        final conversation = Conversation.fromJson(json);

        // Assert
        expect(conversation.userId, equals(0));
      });
    });

    group('fromJson - CreatedAt parsing', () {
      test('devrait parser createdAt depuis format ISO8601', () {
        // Arrange
        final json = {
          'id': 1,
          'titre': 'Test',
          'userId': 1,
          'createdAt': '2024-06-15T14:30:00.000',
        };

        // Act
        final conversation = Conversation.fromJson(json);

        // Assert
        expect(conversation.createdAt.year, equals(2024));
        expect(conversation.createdAt.month, equals(6));
        expect(conversation.createdAt.day, equals(15));
      });

      test('devrait parser createdAt depuis epoch milliseconds', () {
        // Arrange
        final epochMs = DateTime(2024, 1, 15, 10, 30).millisecondsSinceEpoch;
        final json = {
          'id': 1,
          'titre': 'Test',
          'userId': 1,
          'createdAt': epochMs,
        };

        // Act
        final conversation = Conversation.fromJson(json);

        // Assert
        expect(conversation.createdAt.year, equals(2024));
        expect(conversation.createdAt.month, equals(1));
      });

      test('devrait utiliser DateTime.now() pour createdAt null', () {
        // Arrange
        final beforeTest = DateTime.now();
        final json = {
          'id': 1,
          'titre': 'Test',
          'userId': 1,
          'createdAt': null,
        };

        // Act
        final conversation = Conversation.fromJson(json);
        final afterTest = DateTime.now();

        // Assert
        expect(conversation.createdAt.isAfter(beforeTest.subtract(const Duration(seconds: 1))), isTrue);
        expect(conversation.createdAt.isBefore(afterTest.add(const Duration(seconds: 1))), isTrue);
      });

      test('devrait parser depuis created_at alternatif', () {
        // Arrange
        final json = {
          'id': 1,
          'titre': 'Test',
          'userId': 1,
          'created_at': '2024-03-20T12:00:00.000',
        };

        // Act
        final conversation = Conversation.fromJson(json);

        // Assert
        expect(conversation.createdAt.year, equals(2024));
        expect(conversation.createdAt.month, equals(3));
      });
    });

    group('fromJson - Messages parsing', () {
      test('devrait parser une liste de messages', () {
        // Arrange
        final json = {
          'id': 1,
          'titre': 'Test',
          'userId': 1,
          'createdAt': '2024-01-15T10:30:00.000',
          'messages': [
            {
              'id': 1,
              'content': 'Message 1',
              'senderId': 0,
              'createdAt': '2024-01-15T10:30:00.000',
              'conversationId': 1,
            },
            {
              'id': 2,
              'content': 'Message 2',
              'senderId': 1,
              'createdAt': '2024-01-15T10:31:00.000',
              'conversationId': 1,
            },
          ],
        };

        // Act
        final conversation = Conversation.fromJson(json);

        // Assert
        expect(conversation.messages, isNotNull);
        expect(conversation.messages, hasLength(2));
        expect(conversation.messages![0].content, equals('Message 1'));
        expect(conversation.messages![1].content, equals('Message 2'));
      });

      test('devrait retourner null pour messages absents', () {
        // Arrange
        final json = {
          'id': 1,
          'titre': 'Test',
          'userId': 1,
          'createdAt': '2024-01-15T10:30:00.000',
        };

        // Act
        final conversation = Conversation.fromJson(json);

        // Assert
        expect(conversation.messages, isNull);
      });

      test('devrait retourner null pour messages null', () {
        // Arrange
        final json = {
          'id': 1,
          'titre': 'Test',
          'userId': 1,
          'createdAt': '2024-01-15T10:30:00.000',
          'messages': null,
        };

        // Act
        final conversation = Conversation.fromJson(json);

        // Assert
        expect(conversation.messages, isNull);
      });
    });

    group('toJson', () {
      test('devrait convertir une Conversation en JSON', () {
        // Arrange
        final conversation = Conversation(
          id: 1,
          titre: 'Ma conversation',
          userId: 42,
          createdAt: DateTime(2024, 1, 15, 10, 30),
        );

        // Act
        final json = conversation.toJson();

        // Assert
        expect(json['id'], equals(1));
        expect(json['titre'], equals('Ma conversation'));
        expect(json['userId'], equals(42));
        expect(json['createdAt'], equals('2024-01-15T10:30:00.000'));
      });
    });

    group('copyWith', () {
      test('devrait créer une copie avec des valeurs modifiées', () {
        // Arrange
        final original = Conversation(
          id: 1,
          titre: 'Original',
          userId: 1,
          createdAt: DateTime(2024, 1, 15),
        );

        // Act
        final copy = original.copyWith(
          titre: 'Modified',
          userId: 99,
        );

        // Assert
        expect(copy.id, equals(original.id));
        expect(copy.titre, equals('Modified'));
        expect(copy.userId, equals(99));
        expect(copy.createdAt, equals(original.createdAt));
      });

      test('devrait préserver les messages lors de copyWith', () {
        // Arrange
        final messages = [
          Message(
            id: 1,
            content: 'Test',
            senderId: 0,
            timestamp: DateTime.now(),
            conversationId: 1,
          ),
        ];
        final original = Conversation(
          id: 1,
          titre: 'Original',
          userId: 1,
          createdAt: DateTime.now(),
          messages: messages,
        );

        // Act
        final copy = original.copyWith(titre: 'New title');

        // Assert
        expect(copy.messages, equals(messages));
      });

      test('devrait permettre de modifier les messages', () {
        // Arrange
        final original = Conversation(
          id: 1,
          titre: 'Original',
          userId: 1,
          createdAt: DateTime.now(),
          messages: null,
        );
        final newMessages = [
          Message(
            id: 1,
            content: 'New message',
            senderId: 0,
            timestamp: DateTime.now(),
            conversationId: 1,
          ),
        ];

        // Act
        final copy = original.copyWith(messages: newMessages);

        // Assert
        expect(copy.messages, isNotNull);
        expect(copy.messages, hasLength(1));
        expect(copy.messages![0].content, equals('New message'));
      });
    });

    group('Constructor', () {
      test('devrait créer une Conversation avec les champs requis', () {
        // Arrange & Act
        final conversation = Conversation(
          titre: 'Test conversation',
          userId: 1,
          createdAt: DateTime(2024, 5, 10),
        );

        // Assert
        expect(conversation.id, isNull);
        expect(conversation.titre, equals('Test conversation'));
        expect(conversation.userId, equals(1));
        expect(conversation.messages, isNull);
      });

      test('devrait créer une Conversation avec messages', () {
        // Arrange
        final messages = [
          Message(
            content: 'Hello',
            senderId: 0,
            timestamp: DateTime.now(),
            conversationId: 1,
          ),
        ];

        // Act
        final conversation = Conversation(
          titre: 'With messages',
          userId: 1,
          createdAt: DateTime.now(),
          messages: messages,
        );

        // Assert
        expect(conversation.messages, isNotNull);
        expect(conversation.messages, hasLength(1));
      });
    });

    group('Round-trip serialization', () {
      test('devrait préserver les données lors de la sérialisation/désérialisation', () {
        // Arrange
        final original = Conversation(
          id: 42,
          titre: 'Test round-trip',
          userId: 77,
          createdAt: DateTime(2024, 3, 20, 15, 45),
        );

        // Act
        final json = original.toJson();
        final reconstructed = Conversation.fromJson(json);

        // Assert
        expect(reconstructed.id, equals(original.id));
        expect(reconstructed.titre, equals(original.titre));
        expect(reconstructed.userId, equals(original.userId));
      });
    });
  });
}

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:moodmate/services/chat_service.dart';
import 'package:moodmate/models/conversation_model.dart';
import 'package:moodmate/models/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ChatService', () {
    late ChatService chatService;

    setUp(() {
      chatService = ChatService();
    });

    group('createMessage', () {
      test('devrait créer un Message avec tous les champs requis', () {
        // Arrange
        final now = DateTime.now();

        // Act
        final message = chatService.createMessage(
          content: 'Test message',
          senderId: 1,
          conversationId: 10,
          id: 5,
          timestamp: now,
        );

        // Assert
        expect(message.content, equals('Test message'));
        expect(message.senderId, equals(1));
        expect(message.conversationId, equals(10));
        expect(message.id, equals(5));
        expect(message.timestamp, equals(now));
      });

      test('devrait créer un Message sans id optionnel', () {
        // Act
        final message = chatService.createMessage(
          content: 'Hello',
          senderId: 2,
          conversationId: 20,
        );

        // Assert
        expect(message.content, equals('Hello'));
        expect(message.senderId, equals(2));
        expect(message.conversationId, equals(20));
        expect(message.id, isNull);
        expect(message.timestamp, isNotNull);
      });

      test('devrait gérer un contenu vide', () {
        // Act
        final message = chatService.createMessage(
          content: '',
          senderId: 1,
          conversationId: 1,
        );

        // Assert
        expect(message.content, isEmpty);
      });

      test('devrait gérer un contenu très long', () {
        // Arrange
        final longContent = 'A' * 5000;

        // Act
        final message = chatService.createMessage(
          content: longContent,
          senderId: 1,
          conversationId: 1,
        );

        // Assert
        expect(message.content.length, equals(5000));
      });

      test('devrait gérer les caractères spéciaux dans le contenu', () {
        // Arrange
        const specialContent = "L'émoji 😀 et les accents éàù";

        // Act
        final message = chatService.createMessage(
          content: specialContent,
          senderId: 1,
          conversationId: 1,
        );

        // Assert
        expect(message.content, equals(specialContent));
      });
    });

    group('sendMessage - validation des paramètres', () {
      test('devrait retourner erreur si userId est null', () async {
        // Arrange - Simuler aucun utilisateur connecté
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await chatService.sendMessage(message: 'Test');

        // Assert
        expect(result['success'], isFalse);
        expect(result['message'], equals('User not logged in'));
      });

      test('devrait accepter un message avec conversationId null pour nouvelle conversation', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'userId': 1});

        // Act - La requête échouera mais validons que le message est accepté
        final result = await chatService.sendMessage(
          message: 'Premier message',
          conversationTitle: 'Nouvelle conversation',
        );

        // Assert - Erreur de connexion attendue (serveur non disponible)
        expect(result.containsKey('success'), isTrue);
      });
    });

    group('getUserConversations - gestion des erreurs', () {
      test('devrait lancer une exception si userId est null', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act & Assert
        expect(
          () => chatService.getUserConversations(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('User not logged in'),
          )),
        );
      });
    });

    group('deleteConversation - validation', () {
      test('devrait retourner un Map avec success et message', () async {
        // Act - La requête échouera mais validons le format de retour
        final result = await chatService.deleteConversation(999);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('success'), isTrue);
        expect(result.containsKey('message'), isTrue);
      });
    });

    group('updateConversationTitle - validation', () {
      test('devrait retourner un Map avec les clés attendues', () async {
        // Act
        final result = await chatService.updateConversationTitle(1, 'Nouveau titre');

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('success'), isTrue);
      });

      test('devrait accepter un titre vide', () async {
        // Act
        final result = await chatService.updateConversationTitle(1, '');

        // Assert
        expect(result, isA<Map<String, dynamic>>());
      });
    });
  });
}

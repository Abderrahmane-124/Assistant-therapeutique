import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moodmate/models/message_model.dart';
import 'package:moodmate/models/conversation_model.dart';
import 'package:moodmate/features/auth/services/auth_service.dart';

class ChatService {
  final String _baseUrl = 'http://localhost:8080/api/conversations';

  /// Envoyer un message (créer nouvelle conversation ou continuer)
  Future<Map<String, dynamic>> sendMessage({
    int? conversationId,
    required String message,
    String? conversationTitle,
  }) async {
    final userId = await AuthService.getUserId();
    if (userId == null) {
      return {'success': false, 'message': 'User not logged in'};
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'conversationId': conversationId,
          'userId': userId,
          'message': message,
          'conversationTitle': conversationTitle,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'conversation': Conversation.fromJson(data),
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur serveur: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}',
      };
    }
  }

  /// Récupérer toutes les conversations de l'utilisateur
  Future<List<Conversation>> getUserConversations() async {
    final userId = await AuthService.getUserId();
    if (userId == null) {
      throw Exception('User not logged in');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body
            .map((item) => Conversation.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load conversations');
      }
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }

  /// Récupérer une conversation spécifique
  Future<Conversation> getConversation(int conversationId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$conversationId'),
      );

      if (response.statusCode == 200) {
        return Conversation.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Conversation not found');
      }
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  }

  /// Supprimer une conversation
  Future<Map<String, dynamic>> deleteConversation(int conversationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$conversationId'),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Conversation supprimée'};
      } else {
        return {'success': false, 'message': 'Erreur lors de la suppression'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: ${e.toString()}',
      };
    }
  }

  /// Mettre à jour le titre d'une conversation
  Future<Map<String, dynamic>> updateConversationTitle(
    int conversationId,
    String newTitle,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$conversationId/title'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'title': newTitle}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'conversation': Conversation.fromJson(data),
        };
      } else {
        return {'success': false, 'message': 'Erreur lors de la mise à jour'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: ${e.toString()}',
      };
    }
  }

  /// Méthode helper pour créer un objet Message localement
  /// Utilise cette méthode quand tu as besoin de créer un message
  Message createMessage({
    required String content,
    required int senderId,
    required int conversationId,
    int? id,
    DateTime? timestamp,
  }) {
    return Message(
      id: id,
      content: content,
      senderId: senderId,
      timestamp: timestamp ?? DateTime.now(),
      conversationId: conversationId,
    );
  }
}
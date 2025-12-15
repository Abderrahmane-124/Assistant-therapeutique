import 'message_model.dart';

class Conversation {
  final int? id;
  final String titre;
  final int userId;
  final DateTime createdAt;
  final List<Message>? messages;

  Conversation({
    this.id,
    required this.titre,
    required this.userId,
    required this.createdAt,
    this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    // Parse userId from nested user object or direct userId field
    int parseUserId(dynamic data) {
      if (data == null) return 0;
      if (data is Map && data['user'] != null) {
        final user = data['user'];
        if (user is Map && user['id'] != null) {
          return (user['id'] is num) ? (user['id'] as num).toInt() : 0;
        }
      }
      if (data['userId'] != null) {
        return (data['userId'] is num) ? (data['userId'] as num).toInt() : 0;
      }
      return 0;
    }

    // Parse createdAt with fallback
    DateTime parseCreatedAt(dynamic data) {
      final dateStr = data['createdAt'] ?? data['created_at'] ?? data['date'];
      if (dateStr == null) return DateTime.now();
      if (dateStr is String) {
        final parsed = DateTime.tryParse(dateStr);
        return parsed ?? DateTime.now();
      }
      if (dateStr is num) {
        return DateTime.fromMillisecondsSinceEpoch(dateStr.toInt());
      }
      return DateTime.now();
    }

    // Parse messages list
    List<Message>? parseMessages(dynamic data) {
      if (data == null || data['messages'] == null) return null;
      if (data['messages'] is List) {
        try {
          return (data['messages'] as List)
              .map((msg) => Message.fromJson(msg as Map<String, dynamic>))
              .toList();
        } catch (e) {
          print('Error parsing messages: $e');
          return null;
        }
      }
      return null;
    }

    return Conversation(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : json['id'] as int?,
      titre: json['titre']?.toString() ?? json['title']?.toString() ?? 'Sans titre',
      userId: parseUserId(json),
      createdAt: parseCreatedAt(json),
      messages: parseMessages(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Helper method to create a copy with updated values
  Conversation copyWith({
    int? id,
    String? titre,
    int? userId,
    DateTime? createdAt,
    List<Message>? messages,
  }) {
    return Conversation(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      messages: messages ?? this.messages,
    );
  }
}
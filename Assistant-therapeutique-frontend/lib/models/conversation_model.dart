class Conversation {
  final int? id;
  final String titre;
  final int userId;
  final DateTime createdAt;

  Conversation({
    this.id,
    required this.titre,
    required this.userId,
    required this.createdAt,
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

    return Conversation(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : json['id'] as int?,
      titre: json['titre']?.toString() ?? json['title']?.toString() ?? 'Sans titre',
      userId: parseUserId(json),
      createdAt: parseCreatedAt(json),
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
  }) {
    return Conversation(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
class Message {
  final int? id;
  final String content;
  final int senderId;
  final DateTime timestamp;
  final int conversationId;

  Message({
    this.id,
    required this.content,
    required this.senderId,
    required this.timestamp,
    required this.conversationId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    // Parse id
    final id = (json['id'] is num) ? (json['id'] as num).toInt() : json['id'] as int?;

    // Parse content
    final content = json['content']?.toString() ?? '';

    // Parse senderId: accept nested object, number or string
    int parseSenderId(dynamic s) {
      if (s == null) return 0;
      if (s is num) return s.toInt();
      if (s is String) {
        // Map string roles to ids if needed
        if (s.toLowerCase() == 'assistant') return 1;
        if (s.toLowerCase() == 'user') return 0;
        final parsed = int.tryParse(s);
        return parsed ?? 0;
      }
      if (s is Map && s['id'] is num) return (s['id'] as num).toInt();
      return 0;
    }
    final senderRaw = json['sender'] ?? json['senderId'];
    final senderId = parseSenderId(senderRaw);

    // Parse timestamp: accept createdAt / timestamp / date strings or epoch millis
    DateTime parseTimestamp(dynamic t) {
      if (t == null) return DateTime.now();
      if (t is String) {
        final parsed = DateTime.tryParse(t);
        if (parsed != null) return parsed;
      }
      if (t is num) {
        // Assume epoch millis
        return DateTime.fromMillisecondsSinceEpoch(t.toInt());
      }
      return DateTime.now();
    }
    final timestampRaw = json['createdAt'] ?? json['timestamp'] ?? json['date'] ?? json['created_at'];
    final timestamp = parseTimestamp(timestampRaw);

    // Parse conversationId: accept nested object or id
    int parseConversationId(dynamic c) {
      if (c == null) return 0;
      if (c is num) return c.toInt();
      if (c is String) return int.tryParse(c) ?? 0;
      if (c is Map && c['id'] is num) return (c['id'] as num).toInt();
      return 0;
    }
    final conversationRaw = json['conversation'] ?? json['conversationId'] ?? json['conversation_id'];
    final conversationId = parseConversationId(conversationRaw);

    return Message(
      id: id,
      content: content,
      senderId: senderId,
      timestamp: timestamp,
      conversationId: conversationId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'createdAt': timestamp.toIso8601String(),
      'conversationId': conversationId,
    };
  }

  // Helper method to check if message is from user
  bool get isUser => senderId == 0;

  // Helper method to check if message is from assistant
  bool get isAssistant => senderId == 1;

  // Helper method to create a copy with updated values
  Message copyWith({
    int? id,
    String? content,
    int? senderId,
    DateTime? timestamp,
    int? conversationId,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      timestamp: timestamp ?? this.timestamp,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}
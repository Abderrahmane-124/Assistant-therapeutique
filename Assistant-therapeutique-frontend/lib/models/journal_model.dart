class JournalEntry {
  final int? id;
  String content;
  final DateTime createdAt;
  final int? userId; // Changé à nullable

  JournalEntry({
    this.id,
    required this.content,
    required this.createdAt,
    this.userId, // Retiré required
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as int?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as int?, // Maintenant nullable
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }
}
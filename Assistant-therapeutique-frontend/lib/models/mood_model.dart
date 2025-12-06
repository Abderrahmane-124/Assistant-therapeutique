class Mood {
  final int? id;
  final String mood; // e.g., "happy", "sad", "anxious"
  final DateTime? createdAt;
  final int userId; // Assuming userId is sent to the backend

  Mood({this.id, required this.mood, this.createdAt, required this.userId});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mood': mood,
      'createdAt': createdAt?.toIso8601String(),
      'user': {
        // Backend expects a User object with at least the ID
        'id': userId,
      },
    };
  }

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      id: json['id'],
      mood: json['mood'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      userId: json['user']['id'],
    );
  }
}

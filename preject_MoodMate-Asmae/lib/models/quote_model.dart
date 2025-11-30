class Quote {
  final String content;
  final String author;
  final List<String> tags;

  Quote({
    required this.content,
    required this.author,
    required this.tags,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      content: json['content'] ?? '',
      author: json['author'] ?? 'Anonyme',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'author': author,
      'tags': tags,
    };
  }
}

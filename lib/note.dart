class Note {
  final int? id;
  String content;
  bool isFavorite;

  Note({
    this.id,
    required this.content,
    required this.isFavorite,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as int,
      content: json['body'] as String,
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'body': content,
      'is_favorite': isFavorite,
    };
  }
}
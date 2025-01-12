class Book {
  final String id;
  final String title;
  final String author;
  final String? coverUrl;
  final List<Chapter> chapters;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.chapters,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      coverUrl: json['cover_url'],
      chapters: (json['chapters'] as List)
          .map((chapter) => Chapter.fromJson(chapter))
          .toList(),
    );
  }
}

//for chapter
class Chapter {
  final String id;
  final String title;
  final String audioUrl;
  final Duration duration;

  Chapter({
    required this.id,
    required this.title,
    required this.audioUrl,
    required this.duration,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      title: json['title'],
      audioUrl: json['audio_url'],
      duration: Duration(seconds: json['duration_seconds'] ?? 0),
    );
  }
}

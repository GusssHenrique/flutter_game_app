class Game {
  final String id;
  final String title;
  final String genre;
  final String platform;
  final String? imageUrl;
  final String? description;
  final int? releaseYear;
  final String? developer;
  final DateTime createdAt;
  final String? userId;

  Game({
    required this.id,
    required this.title,
    required this.genre,
    required this.platform,
    this.imageUrl,
    this.description,
    this.releaseYear,
    this.developer,
    required this.createdAt,
    this.userId,
  });

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] as String,
      title: map['title'] as String,
      genre: map['genre'] as String,
      platform: map['platform'] as String,
      imageUrl: map['image_url'] as String?,
      description: map['description'] as String?,
      releaseYear: map['release_year'] as int?,
      developer: map['developer'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      userId: map['user_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'genre': genre,
      'platform': platform,
      'image_url': imageUrl,
      'description': description,
      'release_year': releaseYear,
      'developer': developer,
    };
  }
}

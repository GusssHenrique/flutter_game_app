class Review {
  final String id;
  final String gameId;
  final String userId;
  final String? userEmail;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Review({
    required this.id,
    required this.gameId,
    required this.userId,
    this.userEmail,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as String,
      gameId: map['game_id'] as String,
      userId: map['user_id'] as String,
      userEmail: map['user_email'] as String?,
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'game_id': gameId,
      'user_id': userId,
      'user_email': userEmail,
      'rating': rating,
      'comment': comment,
    };
  }

  Review copyWith({
    double? rating,
    String? comment,
  }) {
    return Review(
      id: id,
      gameId: gameId,
      userId: userId,
      userEmail: userEmail,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

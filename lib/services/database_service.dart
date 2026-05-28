import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game.dart';
import '../models/review.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ─────────────────────────────────────────────
  //  GAMES
  // ─────────────────────────────────────────────

  Future<List<Game>> fetchGames({String? searchQuery, String? genre}) async {
    var query = _client.from('games').select();

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('title', '%$searchQuery%');
    }

    if (genre != null && genre != 'Todos') {
      query = query.eq('genre', genre);
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List).map((e) => Game.fromMap(e)).toList();
  }

  Future<Game> fetchGameById(String id) async {
    final response =
        await _client.from('games').select().eq('id', id).single();
    return Game.fromMap(response);
  }

  Future<Game> createGame(Game game) async {
    final data = game.toMap();
    data['user_id'] = _client.auth.currentUser!.id;
    final response = await _client
        .from('games')
        .insert(data)
        .select()
        .single();
    return Game.fromMap(response);
  }

  Future<Game> updateGame(String id, Map<String, dynamic> data) async {
    final response = await _client
        .from('games')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return Game.fromMap(response);
  }

  Future<void> deleteGame(String id) async {
    await _client.from('games').delete().eq('id', id);
  }

  // ─────────────────────────────────────────────
  //  REVIEWS
  // ─────────────────────────────────────────────

  Future<List<Review>> fetchReviewsByGame(String gameId) async {
    final response = await _client
        .from('reviews')
        .select()
        .eq('game_id', gameId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => Review.fromMap(e)).toList();
  }

  Future<Review?> fetchMyReview(String gameId, String userId) async {
    final response = await _client
        .from('reviews')
        .select()
        .eq('game_id', gameId)
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) return null;
    return Review.fromMap(response);
  }

  Future<Review> createReview(Review review) async {
    final response = await _client
        .from('reviews')
        .insert(review.toMap())
        .select()
        .single();
    return Review.fromMap(response);
  }

  Future<Review> updateReview(
      String reviewId, double rating, String? comment) async {
    final response = await _client
        .from('reviews')
        .update({
          'rating': rating,
          'comment': comment,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', reviewId)
        .select()
        .single();
    return Review.fromMap(response);
  }

  Future<void> deleteReview(String reviewId) async {
    await _client.from('reviews').delete().eq('id', reviewId);
  }

  // Média de notas de um jogo
  Future<double> fetchAverageRating(String gameId) async {
    final response = await _client
        .from('reviews')
        .select('rating')
        .eq('game_id', gameId);

    final reviews = response as List;
    if (reviews.isEmpty) return 0;
    final total =
        reviews.fold<double>(0, (sum, e) => sum + (e['rating'] as num));
    return total / reviews.length;
  }
}

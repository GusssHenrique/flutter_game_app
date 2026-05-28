import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'game_form_screen.dart';

class GameDetailScreen extends StatefulWidget {
  final Game game;

  const GameDetailScreen({super.key, required this.game});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  final _db = DatabaseService();
  final _auth = AuthService();

  List<Review> _reviews = [];
  Review? _myReview;
  double _avgRating = 0;
  bool _loading = true;

  // Campos para escrever/editar review
  double _selectedRating = 3;
  final _commentController = TextEditingController();
  bool _savingReview = false;

  static const Color _purple = Color(0xFF6C63FF);
  static const Color _surface = Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final userId = _auth.currentUser?.id ?? '';
      final reviews = await _db.fetchReviewsByGame(widget.game.id);
      final myReview = userId.isNotEmpty
          ? await _db.fetchMyReview(widget.game.id, userId)
          : null;
      final avg = await _db.fetchAverageRating(widget.game.id);

      if (mounted) {
        setState(() {
          _reviews = reviews;
          _myReview = myReview;
          _avgRating = avg;
          if (myReview != null) {
            _selectedRating = myReview.rating;
            _commentController.text = myReview.comment ?? '';
          }
        });
      }
    } catch (e) {
      _showError('Erro ao carregar detalhes: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveReview() async {
    setState(() => _savingReview = true);
    try {
      final user = _auth.currentUser!;
      if (_myReview == null) {
        await _db.createReview(Review(
          id: '',
          gameId: widget.game.id,
          userId: user.id,
          userEmail: user.email,
          rating: _selectedRating,
          comment: _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
          createdAt: DateTime.now(),
        ));
      } else {
        await _db.updateReview(
          _myReview!.id,
          _selectedRating,
          _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Avaliação salva!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
      }
      await _load();
    } catch (e) {
      _showError('Erro ao salvar avaliação: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _savingReview = false);
    }
  }

  Future<void> _deleteReview() async {
    if (_myReview == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        title: Text('Excluir avaliação',
            style: GoogleFonts.poppins(color: Colors.white)),
        content: Text('Deseja excluir sua avaliação?',
            style: GoogleFonts.poppins(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _db.deleteReview(_myReview!.id);
      await _load();
    } catch (e) {
      _showError('Erro ao excluir avaliação.');
    }
  }

  Future<void> _deleteGame() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        title: Text('Excluir jogo',
            style: GoogleFonts.poppins(color: Colors.white)),
        content: Text('Esta ação não pode ser desfeita.',
            style: GoogleFonts.poppins(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _db.deleteGame(widget.game.id);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showError('Erro ao excluir jogo.');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : CustomScrollView(
              slivers: [
                // ── AppBar com imagem ──────────────────────
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  backgroundColor: _surface,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    if (game.userId == _auth.currentUser?.id) ...[
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.white),
                        tooltip: 'Editar',
                        onPressed: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GameFormScreen(game: game),
                            ),
                          );
                          if (updated == true) Navigator.pop(context, true);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent),
                        tooltip: 'Excluir',
                        onPressed: _deleteGame,
                      ),
                    ],
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: game.imageUrl != null &&
                            game.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: game.imageUrl!,
                            fit: BoxFit.cover,
                            color: Colors.black.withOpacity(0.4),
                            colorBlendMode: BlendMode.darken,
                            placeholder: (_, __) => _headerPlaceholder(),
                            errorWidget: (_, __, ___) => _headerPlaceholder(),
                          )
                        : _headerPlaceholder(),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Título e rating ──────────────────
                        Text(game.title,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            )),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFFFD700), size: 20),
                            const SizedBox(width: 4),
                            Text(
                              _avgRating > 0
                                  ? _avgRating.toStringAsFixed(1)
                                  : 'Sem avaliações',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${_reviews.length} avaliação${_reviews.length != 1 ? 'ões' : ''})',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.white38),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ── Chips ────────────────────────────
                        Wrap(
                          spacing: 8,
                          children: [
                            _chip(game.genre, _purple),
                            _chip(game.platform, const Color(0xFF03DAC6)),
                            if (game.releaseYear != null)
                              _chip('${game.releaseYear}', Colors.orange),
                          ],
                        ),
                        const SizedBox(height: 14),

                        if (game.developer != null) ...[
                          Text('Desenvolvedor: ${game.developer}',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: Colors.white54)),
                          const SizedBox(height: 10),
                        ],

                        if (game.description != null &&
                            game.description!.isNotEmpty) ...[
                          Text('Descrição',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              )),
                          const SizedBox(height: 6),
                          Text(game.description!,
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  height: 1.6)),
                          const SizedBox(height: 20),
                        ],

                        const Divider(color: Color(0xFF2A2A4A)),
                        const SizedBox(height: 16),

                        // ── Minha avaliação ──────────────────
                        Text(
                          _myReview == null
                              ? 'Avaliar este jogo'
                              : 'Minha avaliação',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RatingBar.builder(
                          initialRating: _selectedRating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 32,
                          itemPadding:
                              const EdgeInsets.symmetric(horizontal: 2),
                          itemBuilder: (_, __) => const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFD700),
                          ),
                          onRatingUpdate: (r) =>
                              setState(() => _selectedRating = r),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _commentController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Comentário (opcional)',
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _savingReview ? null : _saveReview,
                                child: _savingReview
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : Text(_myReview == null
                                        ? 'Enviar avaliação'
                                        : 'Atualizar avaliação'),
                              ),
                            ),
                            if (_myReview != null) ...[
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                                onPressed: _deleteReview,
                                tooltip: 'Excluir avaliação',
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFF2A2A4A)),
                        const SizedBox(height: 16),

                        // ── Lista de reviews ─────────────────
                        Text('Avaliações',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            )),
                        const SizedBox(height: 12),
                        if (_reviews.isEmpty)
                          Text('Nenhuma avaliação ainda.',
                              style: GoogleFonts.poppins(
                                  color: Colors.white38, fontSize: 13))
                        else
                          ...(_reviews.map((r) => _ReviewTile(review: r))),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _headerPlaceholder() {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: const Center(
        child: Icon(Icons.videogame_asset, color: Colors.white12, size: 80),
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF6C63FF),
                child: Text(
                  (review.userEmail ?? 'U')[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.userEmail ?? 'Usuário',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.white60),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFFFD700), size: 14),
                  const SizedBox(width: 2),
                  Text(review.rating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70)),
                ],
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.comment!,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.white70, height: 1.5)),
          ],
        ],
      ),
    );
  }
}

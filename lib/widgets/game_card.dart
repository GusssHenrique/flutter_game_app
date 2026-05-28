import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game.dart';
import '../services/database_service.dart';

class GameCard extends StatefulWidget {
  final Game game;
  final VoidCallback onTap;

  const GameCard({super.key, required this.game, required this.onTap});

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  final _db = DatabaseService();
  double _avgRating = 0;

  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  Future<void> _loadRating() async {
    try {
      final avg = await _db.fetchAverageRating(widget.game.id);
      if (mounted) setState(() => _avgRating = avg);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    const Color cardColor = Color(0xFF16213E);
    const Color purple = Color(0xFF6C63FF);
    const Color teal = Color(0xFF03DAC6);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A4A)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Imagem
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: widget.game.imageUrl != null && widget.game.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.game.imageUrl!,
                      width: 90,
                      height: 110,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _imagePlaceholder(),
                      errorWidget: (_, __, ___) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),

            // Infos
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.game.title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _chip(widget.game.genre, purple),
                        const SizedBox(width: 6),
                        _chip(widget.game.platform, teal),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (widget.game.developer != null) ...[
                      Text(
                        widget.game.developer!,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white38,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFD700), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _avgRating > 0 ? _avgRating.toStringAsFixed(1) : '—',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right, color: Colors.white24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 90,
      height: 110,
      color: const Color(0xFF1A1A2E),
      child: const Icon(Icons.videogame_asset, color: Colors.white24, size: 32),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

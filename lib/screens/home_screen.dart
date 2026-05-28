import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/game_card.dart';
import 'login_screen.dart';
import 'game_detail_screen.dart';
import 'game_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _db = DatabaseService();
  final _searchController = TextEditingController();

  List<Game> _games = [];
  bool _loading = true;
  String _selectedGenre = 'Todos';

  static const List<String> _genres = [
    'Todos',
    'Ação',
    'RPG',
    'Aventura',
    'Esporte',
    'Estratégia',
    'Terror',
    'Simulação',
    'Luta',
    'Puzzle',
    'Plataforma',
    'Corrida',
    'FPS',
  ];

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    setState(() => _loading = true);
    try {
      final games = await _db.fetchGames(
        searchQuery: _searchController.text,
        genre: _selectedGenre,
      );
      if (mounted) setState(() => _games = games);
    } catch (e) {
      _showError('Erro ao carregar jogos: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
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
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_esports, color: Color(0xFF6C63FF), size: 26),
            const SizedBox(width: 8),
            Text('GameRank',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Adicionar jogo',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              final created = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GameFormScreen()),
              );
              if (created == true) _loadGames();
            },
          ),
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF6C63FF),
              child: Text(
                (user?.email ?? 'U')[0].toUpperCase(),
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Text(user?.email ?? '',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.white54)),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(children: [
                  const Icon(Icons.logout, size: 18),
                  const SizedBox(width: 8),
                  Text('Sair', style: GoogleFonts.poppins()),
                ]),
              ),
            ],
            onSelected: (v) {
              if (v == 'logout') _signOut();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Barra de busca ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar jogos...',
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white54),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          _loadGames();
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => _loadGames(),
              onChanged: (v) {
                if (v.isEmpty) _loadGames();
              },
            ),
          ),

          // ── Filtro por gênero ───────────────────────
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _genres.length,
              itemBuilder: (_, i) {
                final genre = _genres[i];
                final selected = genre == _selectedGenre;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(genre,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: selected ? Colors.white : Colors.white54,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        )),
                    selected: selected,
                    selectedColor: const Color(0xFF6C63FF),
                    backgroundColor: const Color(0xFF1A1A2E),
                    side: BorderSide(
                        color: selected
                            ? const Color(0xFF6C63FF)
                            : const Color(0xFF2A2A4A)),
                    onSelected: (_) {
                      setState(() => _selectedGenre = genre);
                      _loadGames();
                    },
                  ),
                );
              },
            ),
          ),

          // ── Lista de jogos ─────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF6C63FF)))
                : _games.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: _loadGames,
                        color: const Color(0xFF6C63FF),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _games.length,
                          itemBuilder: (_, i) => GameCard(
                            game: _games[i],
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      GameDetailScreen(game: _games[i]),
                                ),
                              );
                              _loadGames();
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videogame_asset_off,
              size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text('Nenhum jogo encontrado',
              style: GoogleFonts.poppins(
                  color: Colors.white38, fontSize: 16)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () async {
              final created = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GameFormScreen()),
              );
              if (created == true) _loadGames();
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar o primeiro jogo'),
          ),
        ],
      ),
    );
  }
}

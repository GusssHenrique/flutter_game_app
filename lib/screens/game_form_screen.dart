import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game.dart';
import '../services/database_service.dart';

class GameFormScreen extends StatefulWidget {
  final Game? game; // null = criação, não-null = edição

  const GameFormScreen({super.key, this.game});

  @override
  State<GameFormScreen> createState() => _GameFormScreenState();
}

class _GameFormScreenState extends State<GameFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseService();

  final _titleController = TextEditingController();
  final _developerController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();

  String _selectedGenre = 'Ação';
  String _selectedPlatform = 'PC';
  bool _loading = false;

  bool get _isEditing => widget.game != null;

  static const List<String> _genres = [
    'Ação', 'RPG', 'Aventura', 'Esporte', 'Estratégia',
    'Terror', 'Simulação', 'Luta', 'Puzzle', 'Plataforma', 'Corrida', 'FPS',
  ];

  static const List<String> _platforms = [
    'PC', 'PlayStation 5', 'PlayStation 4', 'Xbox Series X', 'Xbox One',
    'Nintendo Switch', 'Mobile', 'Multi-plataforma',
  ];

  static const Color _purple = Color(0xFF6C63FF);
  static const Color _surface = Color(0xFF1A1A2E);
  static const Color _bg = Color(0xFF0F0F1A);

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final g = widget.game!;
      _titleController.text = g.title;
      _developerController.text = g.developer ?? '';
      _imageUrlController.text = g.imageUrl ?? '';
      _descriptionController.text = g.description ?? '';
      _yearController.text = g.releaseYear?.toString() ?? '';
      _selectedGenre = g.genre;
      _selectedPlatform = g.platform;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _developerController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final data = {
        'title': _titleController.text.trim(),
        'genre': _selectedGenre,
        'platform': _selectedPlatform,
        'developer': _developerController.text.trim().isEmpty
            ? null
            : _developerController.text.trim(),
        'image_url': _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'release_year': _yearController.text.trim().isEmpty
            ? null
            : int.tryParse(_yearController.text.trim()),
      };

      if (_isEditing) {
        await _db.updateGame(widget.game!.id, data);
      } else {
        final game = Game(
          id: '',
          title: data['title'] as String,
          genre: data['genre'] as String,
          platform: data['platform'] as String,
          developer: data['developer'] as String?,
          imageUrl: data['image_url'] as String?,
          description: data['description'] as String?,
          releaseYear: data['release_year'] as int?,
          createdAt: DateTime.now(),
        );
        await _db.createGame(game);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? 'Jogo atualizado!' : 'Jogo adicionado!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar jogo' : 'Novo jogo'),
        backgroundColor: _surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              _label('Título *'),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'Ex: The Last of Us'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o título' : null,
              ),
              const SizedBox(height: 16),

              // Gênero
              _label('Gênero *'),
              DropdownButtonFormField<String>(
                initialValue: _selectedGenre,
                dropdownColor: _surface,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
                  ),
                ),
                items: _genres
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedGenre = v!),
              ),
              const SizedBox(height: 16),

              // Plataforma
              _label('Plataforma *'),
              DropdownButtonFormField<String>(
                initialValue: _selectedPlatform,
                dropdownColor: _surface,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
                  ),
                ),
                items: _platforms
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedPlatform = v!),
              ),
              const SizedBox(height: 16),

              // Desenvolvedor
              _label('Desenvolvedor'),
              TextFormField(
                controller: _developerController,
                style: const TextStyle(color: Colors.white),
                decoration:
                    const InputDecoration(hintText: 'Ex: Naughty Dog'),
              ),
              const SizedBox(height: 16),

              // Ano
              _label('Ano de lançamento'),
              TextFormField(
                controller: _yearController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(hintText: 'Ex: 2023'),
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final year = int.tryParse(v);
                  if (year == null || year < 1970 || year > 2030) {
                    return 'Ano inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // URL da imagem
              _label('URL da capa (opcional)'),
              TextFormField(
                controller: _imageUrlController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                    hintText: 'https://exemplo.com/imagem.jpg'),
              ),
              const SizedBox(height: 16),

              // Descrição
              _label('Descrição (opcional)'),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: const InputDecoration(
                    hintText: 'Breve descrição do jogo...'),
              ),
              const SizedBox(height: 28),

              // Botão salvar
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: _purple),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_isEditing ? 'Salvar alterações' : 'Adicionar jogo'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white70)),
    );
  }
}

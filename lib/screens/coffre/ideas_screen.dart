import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/idea_block.dart';
import '../../state/idea_provider.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';
import '../atelier/widgets/ham_btn.dart';

class IdeasScreen extends ConsumerStatefulWidget {
  final VoidCallback onMenu;
  const IdeasScreen({super.key, required this.onMenu});

  @override
  ConsumerState<IdeasScreen> createState() => _IdeasScreenState();
}

class _IdeasScreenState extends ConsumerState<IdeasScreen> {
  bool _showForm = false;
  String? _editingId;
  final _contentCtrl = TextEditingController();
  String _selectedCategory = 'Général';

  final List<String> _categories = [
    'Général',
    'Personnage',
    'Lieu',
    'Phrase',
    'Idée Brute',
    'Ambiance',
  ];

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_contentCtrl.text.trim().isEmpty) return;
    if (_editingId != null) {
      ref.read(ideaProvider.notifier).updateIdea(
        _editingId!,
        _contentCtrl.text.trim(),
        _selectedCategory,
      );
    } else {
      ref.read(ideaProvider.notifier).addIdea(
        _contentCtrl.text.trim(),
        _selectedCategory,
        [],
      );
    }
    _contentCtrl.clear();
    setState(() {
      _showForm = false;
      _editingId = null;
      _selectedCategory = 'Général';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Coffre mis à jour ! 💎',
          style: StoryText.sans(size: 13, color: C.text),
        ),
        backgroundColor: C.surface,
      ),
    );
  }

  void _showRandomDialog() {
    final idea = ref.read(ideaProvider.notifier).pickRandom();
    if (idea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le coffre est vide !',
              style: StoryText.sans(size: 13, color: C.text)),
          backgroundColor: C.surface,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: C.surface,
        title: Text('✦ Pige : ${idea.category}',
            style: StoryText.serif(size: 16, weight: FontWeight.w700)),
        content: Text(idea.content,
            style: StoryText.sans(size: 15, style: FontStyle.italic)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Merci !',
                style: StoryText.mono(size: 12, color: C.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ideas = ref.watch(ideaProvider);

    return Stack(
      children: [
        const GridBg(opacity: 0.25),
        const MeshBlobs(warm: true),
        Positioned.fill(
          child: Column(
            children: [
              const SizedBox(height: 56),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        HamBtn(onMenu: widget.onMenu),
                        IconButton(
                          icon: Icon(
                            _showForm ? Icons.close : Icons.add,
                            color: C.primary,
                          ),
                          onPressed: () =>
                              setState(() => _showForm = !_showForm),
                        ),
                      ],
                    ),
                    Text('✦ IDÉES',
                        style: StoryText.mono(
                            size: 10,
                            color: C.primary,
                            letterSpacing: 3)),
                    const SizedBox(height: 4),
                    Text('Le Coffre à Idées',
                        style: StoryText.serif(
                            size: 28, weight: FontWeight.w700)),
                    Text('${ideas.length} pépite${ideas.length != 1 ? 's' : ''}',
                        style: StoryText.sans(
                            size: 13,
                            color: C.textMuted,
                            style: FontStyle.italic)),
                  ],
                ),
              ),

              // Formulaire
              if (_showForm) _buildForm(),

              // Liste
              Expanded(
                child: ideas.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  itemCount: ideas.length,
                  itemBuilder: (_, i) => _IdeaCard(
                    idea: ideas[i],
                    onDelete: () => ref
                        .read(ideaProvider.notifier)
                        .deleteIdea(ideas[i].id),
                    onEdit: () => setState(() {
                      _showForm = true;
                      _editingId = ideas[i].id;
                      _contentCtrl.text = ideas[i].content;
                      _selectedCategory = ideas[i].category;
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),

        // FAB — pige aléatoire
        Positioned(
          bottom: 100,
          right: 20,
          child: FloatingActionButton(
            onPressed: _showRandomDialog,
            backgroundColor: C.primary,
            child: const Icon(Icons.casino, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _editingId != null ? 'Modifier l\'idée :' : 'Nouvelle pépite :',
            style: StoryText.mono(size: 11, color: C.textMuted),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _contentCtrl,
            maxLines: 3,
            style: StoryText.sans(size: 14, color: C.text),
            decoration: InputDecoration(
              hintText: 'Écris ton idée ici...',
              hintStyle: StoryText.sans(size: 14, color: C.textDim),
              filled: true,
              fillColor: C.bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            dropdownColor: C.surface,
            style: StoryText.sans(size: 13, color: C.text),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) => setState(() => _selectedCategory = val!),
            decoration: InputDecoration(
              labelText: 'Catégorie',
              labelStyle: StoryText.sans(size: 12, color: C.textMuted),
              filled: true,
              fillColor: C.bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: C.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                _editingId != null ? 'METTRE À JOUR' : 'AJOUTER AU COFFRE',
                style: StoryText.mono(size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('💎', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('Ton coffre est vide.',
              style: StoryText.serif(size: 18, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Ajoute ta première pépite !',
              style: StoryText.sans(
                  size: 13, color: C.textMuted, style: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _IdeaCard extends StatelessWidget {
  final IdeaBlock idea;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _IdeaCard({
    required this.idea,
    required this.onDelete,
    required this.onEdit,
  });

  Color _categoryColor() {
    switch (idea.category) {
      case 'Personnage':
        return const Color(0xFF60A5FA);
      case 'Lieu':
        return const Color(0xFF34D399);
      case 'Phrase':
        return const Color(0xFFA78BFA);
      case 'Idée Brute':
        return C.primary;
      case 'Ambiance':
        return const Color(0xFFFBBF24);
      default:
        return C.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(idea.category,
                    style: StoryText.mono(size: 9, color: color)),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_outlined, size: 16, color: C.accent),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        size: 16, color: Colors.redAccent),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(idea.content,
              style: StoryText.sans(size: 14, color: C.text)),
          const SizedBox(height: 10),
          Text(
            '${idea.createdAt.day}/${idea.createdAt.month}/${idea.createdAt.year}',
            style: StoryText.mono(size: 10, color: C.textDim),
          ),
        ],
      ),
    );
  }
}
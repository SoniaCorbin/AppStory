import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../models/gallery_item.dart';
import '../../state/gallery_provider.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';
import '../atelier/widgets/ham_btn.dart';

class GalleryScreen extends ConsumerWidget {
  final VoidCallback onMenu;
  const GalleryScreen({super.key, required this.onMenu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items     = ref.watch(galleryProvider);
    final favorites = items.where((i) => i.isFavorite).length;

    return Stack(
      children: [
        const GridBg(opacity: 0.25),
        const MeshBlobs(),
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
                        HamBtn(onMenu: onMenu),
                        IconButton(
                          icon: Icon(Icons.add_photo_alternate_rounded,
                              color: C.primary),
                          onPressed: () => _pickImage(context, ref),
                        ),
                      ],
                    ),
                    Text('◉ GALERIE',
                        style: StoryText.mono(
                            size: 10, color: C.primary, letterSpacing: 3)),
                    const SizedBox(height: 4),
                    Text('Galerie d\'inspiration',
                        style: StoryText.serif(
                            size: 28, weight: FontWeight.w700)),
                    Text(
                        '${items.length} image${items.length != 1 ? 's' : ''} · $favorites favori${favorites != 1 ? 's' : ''}',
                        style: StoryText.sans(
                            size: 13,
                            color: C.textMuted,
                            style: FontStyle.italic)),
                  ],
                ),
              ),

              // Grille
              Expanded(
                child: items.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                  padding:
                  const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _GalleryCard(
                    item: items[i],
                    onFavorite: () => ref
                        .read(galleryProvider.notifier)
                        .toggleFavorite(items[i].id),
                    onDelete: () => ref
                        .read(galleryProvider.notifier)
                        .deleteItem(items[i].id),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await ref.read(galleryProvider.notifier).addItem(picked.path);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🖼️', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('Aucune image encore.',
              style: StoryText.serif(size: 18, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Ajoute des images d\'inspiration !',
              style: StoryText.sans(
                  size: 13, color: C.textMuted, style: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final GalleryItem item;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;

  const _GalleryCard({
    required this.item,
    required this.onFavorite,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image locale
          Image.file(
            File(item.imagePath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: C.surface,
              child: Icon(Icons.broken_image_rounded,
                  color: C.textDim, size: 40),
            ),
          ),

          // Gradient bas
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),

          // Bouton favori
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onFavorite,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: item.isFavorite
                      ? Colors.red
                      : Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),

          // Bouton supprimer
          Positioned(
            top: 8,
            left: 8,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline,
                    color: Colors.white, size: 16),
              ),
            ),
          ),

          // Titre si présent
          if (item.title.isNotEmpty)
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Text(
                item.title,
                style: StoryText.sans(
                    size: 12,
                    color: Colors.white,
                    weight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
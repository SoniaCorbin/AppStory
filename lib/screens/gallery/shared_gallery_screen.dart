import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/story_tokens.dart';
import '../../core/theme/story_text_styles.dart';
import '../../services/gallery_share_service.dart';
import '../../widgets/backgrounds/grid_bg.dart';
import '../../widgets/backgrounds/mesh_blobs.dart';

class SharedGalleryScreen extends StatefulWidget {
  const SharedGalleryScreen({super.key});

  @override
  State<SharedGalleryScreen> createState() => _SharedGalleryScreenState();
}

class _SharedGalleryScreenState extends State<SharedGalleryScreen> {
  List<SharedGalleryItem> _items = [];
  bool _loading = true;

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await GalleryShareService.getSharedImages();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _delete(SharedGalleryItem item) async {
    await GalleryShareService.deleteSharedImage(item.id, item.imageUrl);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GridBg(opacity: 0.25),
          const MeshBlobs(),
          Positioned.fill(
            child: Column(
              children: [
                const SizedBox(height: 56),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 16, 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: C.textDim),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('◉ GALERIE PARTAGÉE',
                                style: StoryText.mono(
                                    size: 10,
                                    color: C.primary,
                                    letterSpacing: 2)),
                            Text('Co-auteurs',
                                style: StoryText.serif(
                                    size: 16, weight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh_rounded, color: C.primary),
                        onPressed: _load,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _loading
                      ? Center(
                      child: CircularProgressIndicator(color: C.primary))
                      : _items.isEmpty
                      ? Center(
                    child: Text(
                      'Aucune image partagée encore.',
                      style: StoryText.sans(
                          size: 13,
                          color: C.textDim,
                          style: FontStyle.italic),
                    ),
                  )
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
                    itemCount: _items.length,
                    itemBuilder: (_, i) {
                      final item = _items[i];
                      final isMe = item.userId == _currentUserId;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(
                                    color: C.surface,
                                    child: Icon(
                                        Icons.broken_image_rounded,
                                        color: C.textDim,
                                        size: 40),
                                  ),
                            ),
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black
                                          .withValues(alpha: 0.55),
                                    ],
                                    stops: const [0.5, 1.0],
                                  ),
                                ),
                              ),
                            ),
                            if (isMe)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => _delete(item),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black
                                          .withValues(alpha: 0.35),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                        size: 16),
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              right: 10,
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  if (item.title.isNotEmpty)
                                    Text(
                                      item.title,
                                      style: StoryText.sans(
                                          size: 12,
                                          color: Colors.white,
                                          weight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow:
                                      TextOverflow.ellipsis,
                                    ),
                                  Text(
                                    item.userName,
                                    style: StoryText.mono(
                                        size: 9,
                                        color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
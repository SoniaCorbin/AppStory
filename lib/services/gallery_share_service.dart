import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SharedGalleryItem {
  final String id;
  final String userId;
  final String userName;
  final String imageUrl;
  final String title;
  final DateTime createdAt;

  const SharedGalleryItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.imageUrl,
    required this.title,
    required this.createdAt,
  });

  factory SharedGalleryItem.fromMap(Map<String, dynamic> map) {
    return SharedGalleryItem(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      userName: map['user_name'] as String,
      imageUrl: map['image_url'] as String,
      title: map['title'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class GalleryShareService {
  static final _client = Supabase.instance.client;

  static Future<void> shareImage({
    required String imagePath,
    required String title,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final file = File(imagePath);
    final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Upload dans Supabase Storage
    await _client.storage.from('gallery').upload(fileName, file);

    final imageUrl =
    _client.storage.from('gallery').getPublicUrl(fileName);

    final name = user.userMetadata?['name'] as String? ?? 'Écrivain';

    await _client.from('shared_gallery').insert({
      'user_id': user.id,
      'user_name': name,
      'image_url': imageUrl,
      'title': title,
    });
  }

  static Future<List<SharedGalleryItem>> getSharedImages() async {
    final response = await _client
        .from('shared_gallery')
        .select()
        .order('created_at', ascending: false)
        .limit(50);

    return (response as List)
        .map((e) => SharedGalleryItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> deleteSharedImage(String id, String imageUrl) async {
    final fileName = imageUrl.split('/').last;
    await _client.storage.from('gallery').remove([fileName]);
    await _client.from('shared_gallery').delete().eq('id', id);
  }
}
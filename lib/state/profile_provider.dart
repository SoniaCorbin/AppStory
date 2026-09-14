import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final profileProvider =
StateNotifierProvider<ProfileNotifier, String>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<String> {
  ProfileNotifier() : super('Écrivain') {
    _load();
  }

  Box get _box => Hive.box('settings');

  void _load() {
    state = _box.get('profile_name', defaultValue: 'Écrivain') as String;
  }

  Future<void> setName(String name) async {
    final trimmed = name.trim().isEmpty ? 'Écrivain' : name.trim();
    await _box.put('profile_name', trimmed);
    state = trimmed;
  }
}
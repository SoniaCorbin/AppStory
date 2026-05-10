import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../core/constants/story_tokens.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(true) {
    _load();
  }

  void _load() {
    final settings = Hive.box('settings');
    final isDark = settings.get('isDark', defaultValue: true) as bool;
    C.isDark = isDark;
    state = isDark;
  }

  Future<void> toggle() async {
    final newValue = !state;
    final settings = Hive.box('settings');
    await settings.put('isDark', newValue);
    C.isDark = newValue;
    state = newValue;
  }
}
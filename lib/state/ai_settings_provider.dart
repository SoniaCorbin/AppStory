import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../services/secure_storage_service.dart';

/// État des paramètres du Mode IA.
class AiSettings {
  final bool enabled;
  final bool hasApiKey;
  final String? apiKeyPreview;

  const AiSettings({
    required this.enabled,
    required this.hasApiKey,
    this.apiKeyPreview,
  });

  AiSettings copyWith({
    bool? enabled,
    bool? hasApiKey,
    String? apiKeyPreview,
    bool clearKeyPreview = false,
  }) {
    return AiSettings(
      enabled: enabled ?? this.enabled,
      hasApiKey: hasApiKey ?? this.hasApiKey,
      apiKeyPreview:
          clearKeyPreview ? null : (apiKeyPreview ?? this.apiKeyPreview),
    );
  }
}

final aiSettingsProvider =
    StateNotifierProvider<AiSettingsNotifier, AiSettings>((ref) {
  return AiSettingsNotifier();
});

class AiSettingsNotifier extends StateNotifier<AiSettings> {
  AiSettingsNotifier()
      : super(const AiSettings(enabled: false, hasApiKey: false)) {
    _load();
  }

  Box get _box => Hive.box('settings');

  Future<void> _load() async {
    final enabled = _box.get('ai_enabled', defaultValue: false) as bool;
    final key = await SecureStorageService.getApiKey();
    final hasKey = key != null && key.isNotEmpty;
    state = AiSettings(
      enabled: enabled,
      hasApiKey: hasKey,
      apiKeyPreview: hasKey ? _maskKey(key) : null,
    );
  }

  String _maskKey(String key) {
    if (key.length < 12) return '••••';
    return '${key.substring(0, 7)}…${key.substring(key.length - 4)}';
  }

  Future<void> setEnabled(bool value) async {
    await _box.put('ai_enabled', value);
    state = state.copyWith(enabled: value);
  }

  /// Nettoie la clé : enlève espaces, retours à la ligne, et extrait
  /// la partie `sk-ant-...` même si elle est entourée d'autre texte.
  static String _cleanKey(String raw) {
    // On cherche la première occurrence de "sk-ant-" et on prend
    // tous les caractères valides après (lettres, chiffres, tirets, underscores)
    final match = RegExp(r'sk-ant-[A-Za-z0-9_\-]+').firstMatch(raw);
    if (match != null) return match.group(0)!;
    // Sinon on retire juste espaces et retours à la ligne
    return raw.replaceAll(RegExp(r'\s+'), '').trim();
  }

  Future<void> setApiKey(String key) async {
    final cleaned = _cleanKey(key);
    await SecureStorageService.setApiKey(cleaned);
    state = state.copyWith(
      hasApiKey: cleaned.isNotEmpty,
      apiKeyPreview:
          cleaned.isNotEmpty ? _maskKey(cleaned) : null,
      clearKeyPreview: cleaned.isEmpty,
    );
  }

  Future<void> clearApiKey() async {
    await SecureStorageService.clearApiKey();
    // Quand on enlève la clé, on désactive aussi le mode IA
    await _box.put('ai_enabled', false);
    state = const AiSettings(enabled: false, hasApiKey: false);
  }
}

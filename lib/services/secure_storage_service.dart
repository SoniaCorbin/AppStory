import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

/// Service responsable de la sécurité :
/// - génère / récupère la clé de chiffrement Hive
/// - la stocke dans le Keystore Android (hardware-backed)
class SecureStorageService {
  static const _hiveKeyName = 'storyblocks_hive_key_v1';
  static const _apiKeyName = 'anthropic_api_key';

  // Options Android : utilise le Keystore + EncryptedSharedPreferences
  static const _options = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static final _storage = const FlutterSecureStorage(aOptions: _options);

  /// Récupère la clé de chiffrement Hive (ou en crée une nouvelle au 1er lancement).
  /// La clé est une List<int> de 32 octets (AES-256).
  static Future<List<int>> getHiveEncryptionKey() async {
    final stored = await _storage.read(key: _hiveKeyName);

    if (stored != null) {
      // ignore: avoid_print
      print('[SecureStorage] ✅ Clé existante récupérée');
      return base64Url.decode(stored);
    }

    // Pas de clé : on en génère une nouvelle (32 octets aléatoires)
    final newKey = Hive.generateSecureKey();
    await _storage.write(
      key: _hiveKeyName,
      value: base64UrlEncode(newKey),
    );
    // ignore: avoid_print
    print('[SecureStorage] 🆕 Nouvelle clé générée et sauvegardée');
    return newKey;
  }

  // ============== Clé API Anthropic ==============

  /// Récupère la clé API Anthropic stockée.
  static Future<String?> getApiKey() async {
    return await _storage.read(key: _apiKeyName);
  }

  /// Stocke la clé API Anthropic dans le Keystore.
  static Future<void> setApiKey(String key) async {
    await _storage.write(key: _apiKeyName, value: key);
  }

  /// Efface la clé API Anthropic.
  static Future<void> clearApiKey() async {
    await _storage.delete(key: _apiKeyName);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'models/block_type.dart';
import 'models/coffre_item.dart';
import 'services/secure_storage_service.dart';
import 'storage/agenda_record.dart';
import 'storage/coffre_record.dart';
import 'storage/library_record.dart';
import 'storage/story_record.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ---------- HIVE INIT ----------
  await Hive.initFlutter();

  // Récupère / génère la clé de chiffrement AES-256
  // stockée dans le Keystore Android (hardware-backed)
  final encryptionKey = await SecureStorageService.getHiveEncryptionKey();
  final cipher = HiveAesCipher(encryptionKey);

  // ---------- ENREGISTREMENT DES ADAPTERS ----------
  Hive.registerAdapter(BlockTypeAdapter());       // typeId 0
  Hive.registerAdapter(StoryRecordAdapter());     // typeId 1
  Hive.registerAdapter(BlockRecordAdapter());     // typeId 2
  Hive.registerAdapter(CoffreItemTypeAdapter());  // typeId 3
  Hive.registerAdapter(CoffreRecordAdapter());    // typeId 4
  Hive.registerAdapter(AgendaRecordAdapter());    // typeId 5
  Hive.registerAdapter(LibraryRecordAdapter());   // typeId 6

  // ---------- OUVERTURE DES BOÎTES CHIFFRÉES ----------
  // Toutes les données utilisateur sont chiffrées sur disque
  await Hive.openBox<StoryRecord>('stories', encryptionCipher: cipher);
  await Hive.openBox<CoffreRecord>('coffre', encryptionCipher: cipher);
  await Hive.openBox<AgendaRecord>('agenda', encryptionCipher: cipher);
  await Hive.openBox<LibraryRecord>('library', encryptionCipher: cipher);

  // La box settings reste en clair (que des bool : onboarded, isDark, etc.)
  await Hive.openBox('settings');

  runApp(
    const ProviderScope(
      child: StoryBlocksApp(),
    ),
  );
}

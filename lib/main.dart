import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'models/block_type.dart';
import 'storage/story_record.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Hive
  await Hive.initFlutter();

  // Enregistrement des adaptateurs
  Hive.registerAdapter(BlockTypeAdapter());
  Hive.registerAdapter(BlockRecordAdapter());
  Hive.registerAdapter(StoryRecordAdapter());

  // Ouverture des boîtes
  await Hive.openBox<StoryRecord>('stories');

  runApp(
    const ProviderScope(
      child: StoryBlocksApp(), // Utilise ton application principale
    ),
  );
}
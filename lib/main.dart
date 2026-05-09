import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'models/block_type.dart';
import 'models/coffre_item.dart';
import 'storage/agenda_record.dart';
import 'storage/coffre_record.dart';
import 'storage/story_record.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Hive
  await Hive.initFlutter();

  // Enregistrement des adaptateurs
  Hive.registerAdapter(BlockTypeAdapter());          // typeId 0
  Hive.registerAdapter(StoryRecordAdapter());        // typeId 1
  Hive.registerAdapter(BlockRecordAdapter());        // typeId 2
  Hive.registerAdapter(CoffreItemTypeAdapter());     // typeId 3
  Hive.registerAdapter(CoffreRecordAdapter());       // typeId 4
  Hive.registerAdapter(AgendaRecordAdapter());       // typeId 5

  // Ouverture des boîtes
  await Hive.openBox<StoryRecord>('stories');
  await Hive.openBox<CoffreRecord>('coffre');
  await Hive.openBox<AgendaRecord>('agenda');
  await Hive.openBox('settings'); // box type-less pour les flags simples

  runApp(
    const ProviderScope(
      child: StoryBlocksApp(),
    ),
  );
}

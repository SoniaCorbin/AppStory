import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/story_tokens.dart';
import '../../models/story.dart';
import '../../state/story_provider.dart';
import '../../state/theme_provider.dart';
import '../profil/profil_screen.dart';
import '../agenda/agenda_screen.dart';
import '../editor/editor_screen.dart';
import '../search/search_screen.dart';
import '../search/search_screen.dart';

import '../atelier/atelier_screen.dart';
import '../coffre/coffre_screen.dart';
import '../home/home_screen.dart';
import '../story/story_detail_screen.dart';

import '../../widgets/navigation/bottom_nav.dart';
import '../../widgets/navigation/drawer_menu.dart';
import 'nav_items.dart';

class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  NavTab active = NavTab.home;
  bool showDrawer = false;

  void _openStory(Story s) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryDetailScreen(story: s),
      ),
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SearchScreen(),
      ),
    );
  }

  /// Ouvre l'éditeur pour la dernière histoire sauvegardée.
  /// Utilisé après "Sauvegarder + Développer" dans l'Atelier.
  void _openEditor() {
    final latest = ref.read(storyProvider.notifier).latest;
    if (latest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sauvegarde d\'abord une amorce !')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditorScreen(story: latest),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Force le rebuild quand le thème change (sinon la navbar reste figée)
    ref.watch(themeProvider);

    final Widget content;

    if (active == NavTab.home) {
      content = HomeScreen(
        onMenu: () => setState(() => showDrawer = true),
        onSearch: _openSearch,
        onStory: _openStory,
      );
    } else if (active == NavTab.atelier) {
      content = AtelierScreen(
        onMenu: () => setState(() => showDrawer = true),
        onEdit: _openEditor,
      );
    } else if (active == NavTab.coffre) {
      content = CoffreScreen(
        onMenu: () => setState(() => showDrawer = true),
      );
    } else if (active == NavTab.agenda) {
      content = AgendaScreen(
        onMenu: () => setState(() => showDrawer = true),
      );
    } else if (active == NavTab.profil) {
      content = ProfilScreen(
        onMenu: () => setState(() => showDrawer = true),
      );
    } else {
      content = _PlaceholderTab(title: active.label);
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: content),

          BottomNav(
            active: active,
            onNav: (t) => setState(() => active = t),
          ),

          if (showDrawer)
            DrawerMenu(
              active: active,
              onNav: (t) => setState(() => active = t),
              onClose: () => setState(() => showDrawer = false),
            ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String title;
  const _PlaceholderTab({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: TextStyle(
          color: C.text,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

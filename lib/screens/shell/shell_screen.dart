import 'package:flutter/material.dart';

import '../../core/constants/story_tokens.dart';
import '../../models/story.dart';
import '../profil/profil_screen.dart';
import '../agenda/agenda_screen.dart';

import '../atelier/atelier_screen.dart';
import '../coffre/coffre_screen.dart';
import '../home/home_screen.dart';
import '../story/story_detail_screen.dart';

import '../../widgets/navigation/bottom_nav.dart';
import '../../widgets/navigation/drawer_menu.dart';
import 'nav_items.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search (à venir)')),
    );
  }

  void _openEditor() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Editor (à venir)')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        style: const TextStyle(
          color: C.text,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
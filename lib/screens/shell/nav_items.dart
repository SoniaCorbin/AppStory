import 'package:flutter/material.dart';

enum NavTab { home, atelier, coffre, idees, stats, galerie, agenda, profil }

extension NavTabX on NavTab {
  String get id => switch (this) {
    NavTab.home    => 'home',
    NavTab.atelier => 'atelier',
    NavTab.coffre  => 'coffre',
    NavTab.idees   => 'idees',
    NavTab.stats   => 'stats',
    NavTab.galerie => 'galerie',
    NavTab.agenda  => 'agenda',
    NavTab.profil  => 'profil',
  };

  String get label => switch (this) {
    NavTab.home    => 'Accueil',
    NavTab.atelier => 'Atelier',
    NavTab.coffre  => 'Coffre',
    NavTab.idees   => 'Idées',
    NavTab.stats   => 'Stats',
    NavTab.galerie => 'Galerie',
    NavTab.agenda  => 'Agenda',
    NavTab.profil  => 'Profil',
  };

  IconData get icon => switch (this) {
    NavTab.home    => Icons.grid_view_rounded,
    NavTab.atelier => Icons.science_rounded,
    NavTab.coffre  => Icons.diamond_rounded,
    NavTab.idees   => Icons.lightbulb_rounded,
    NavTab.stats   => Icons.trending_up_rounded,
    NavTab.galerie => Icons.collections_rounded,
    NavTab.agenda  => Icons.calendar_month_rounded,
    NavTab.profil  => Icons.person_rounded,
  };
}
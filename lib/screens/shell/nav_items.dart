import 'package:flutter/material.dart';

enum NavTab { home, atelier, coffre, agenda, profil }

extension NavTabX on NavTab {
  String get id => switch (this) {
    NavTab.home => 'home',
    NavTab.atelier => 'atelier',
    NavTab.coffre => 'coffre',
    NavTab.agenda => 'agenda',
    NavTab.profil => 'profil',
  };

  String get label => switch (this) {
    NavTab.home => 'Accueil',
    NavTab.atelier => 'Atelier',
    NavTab.coffre => 'Coffre',
    NavTab.agenda => 'Agenda',
    NavTab.profil => 'Profil',
  };

  IconData get icon => switch (this) {
    NavTab.home => Icons.grid_view_rounded,
    NavTab.atelier => Icons.science_rounded,
    NavTab.coffre => Icons.diamond_rounded,
    NavTab.agenda => Icons.calendar_month_rounded,
    NavTab.profil => Icons.person_rounded,
  };
}

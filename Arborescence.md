# Arborescence du Projet AppStory 📖

Voici la structure complète et organisée du projet Flutter **AppStory**.

## 📂 Racines et Configuration
- `android/` : Projet natif Android (Configuration, icônes, permissions).
- `assets/` : Ressources statiques de l'application.
    - `fonts/` : Polices de caractères (DMMono, DMSans, PlayfairDisplay).
    - `images/` : Illustrations et ressources graphiques.
- `pubspec.yaml` : Fichier de configuration maître (Dépendances, assets, version).
- `Arborescence.md` : Ce fichier guide.

## 🏗️ Architecture du Code (`lib/`)

### 核心 `core/` (Fondations)
- `constants/` : `story_tokens.dart` (Couleurs, espacements, rayons).
- `routing/` : `routes.dart` (Gestion de la navigation).
- `theme/` : `story_theme.dart` (Configuration globale de l'apparence).
- `utils/` : Fonctions utilitaires diverses.

### 🧩 `widgets/` (Composants Réutilisables)
- `backgrounds/` : Styles d'arrière-plan de l'app.
- `buttons/` : Différents styles de boutons.
- `chips/` : Éléments de sélection/filtres.
- `common/` : `app_scaffold.dart`, `separators.dart`.
- `navigation/` : Barres de navigation et onglets.
- `sheets/` : `base_sheet.dart` et autres panneaux coulissants.

### 📱 `screens/` (Écrans de l'application)
- `agenda/` : Gestion du calendrier et des événements.
- `atelier/` : Espace de création et outils.
- `coffre/` : Inventaire des items et ressources.
- `editor/` : L'éditeur principal (`block_tabs.dart`, `editor_screen.dart`).
- `home/` : Écran d'accueil principal.
- `onboarding/` : Parcours de bienvenue.
- `profil/` : Paramètres et profil utilisateur.
- `search/` : Recherche d'histoires et d'items.
- `shell/` : Structure principale avec navigation (`shell_screen.dart`).
- `splash/` : Écran de chargement initial.
- `story/` : Lecture et affichage d'une histoire (`export_sheet.dart`).

### ⚙️ `state/` (Gestion d'État - Riverpod)
- `app_state.dart` : État global de l'application.
- `atelier_state.dart` & `atelier_provider.dart` : Logique de l'atelier.
- `agenda_state.dart`, `search_state.dart`, `onboarding_state.dart`.

### 📦 `models/` (Classes de Données)
- `story.dart`, `block_type.dart`, `note_type.dart`.
- `user_profile.dart`, `agenda_entry.dart`, `assembled_block.dart`.
- `coffre_item.dart`.

### 💾 `data/` (Sources de Données)
- `mock/` : Données de test (Simulations).
- `repositories/` : Gestion de la récupération des données.

### 🛠️ `dev/` (Outils de Développement)
- `preview/` : `device_frame.dart` (Pour prévisualiser l'app).
- `tweaks/` : `tweaks_panel.dart` (Pour ajuster les réglages à la volée).

---
*Dernière mise à jour : 2024-05-22*

## 🌳 Vue Graphique
```text
AppStory/
├── android/
├── assets/
│   ├── fonts/
│   │   ├── DMMono/
│   │   ├── DMSans/
│   │   └── PlayfairDisplay/
│   └── images/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── routing/
│   │   ├── theme/
│   │   └── utils/
│   ├── data/
│   │   ├── mock/
│   │   └── repositories/
│   ├── dev/
│   │   ├── preview/
│   │   └── tweaks/
│   ├── models/
│   ├── screens/
│   │   ├── agenda/    ├── home/       ├── splash/
│   │   ├── atelier/   ├── onboarding/ ├── story/
│   │   ├── coffre/    ├── profil/     └── ...
│   │   └── editor/    └── search/
│   ├── state/
│   ├── widgets/
│   ├── app.dart
│   └── main.dart
├── test/
└── pubspec.yaml
```

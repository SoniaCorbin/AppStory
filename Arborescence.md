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

### 🧩 `widgets/` (Composants Réutilisables)
- `backgrounds/` : Styles d'arrière-plan de l'app (`grid_bg.dart`, `mesh_blobs.dart`).
- `chips/` : Éléments de sélection/filtres (`block_chip.dart`).
- `navigation/` : Barres de navigation et onglets (`bottom_nav.dart`, `drawer_menu.dart`).

### 📱 `screens/` (Écrans de l'application)
- `agenda/` : Gestion du calendrier et des événements.
- `atelier/` : Espace de création et outils (Génération d'amorces).
- `coffre/` : Inventaire des items et ressources.
- `editor/` : L'éditeur principal (`editor_screen.dart`).
- `home/` : Écran d'accueil principal.
- `onboarding/` : Parcours de bienvenue.
- `profil/` : Paramètres et profil utilisateur.
- `shell/` : Structure principale avec navigation (`shell_screen.dart`).
- `splash/` : Écran de chargement initial.
- `story/` : Lecture et affichage d'une histoire détaillée.

### ⚙️ `state/` (Gestion d'État - Riverpod)
- `story_provider.dart` : Gestion des histoires et persistance.
- `atelier_state.dart` & `atelier_provider.dart` : Logique de l'atelier de création.

### 📦 `models/` (Classes de Données)
- `story.dart`, `block_type.dart`, `assembled_block.dart`.
- `agenda_event.dart`, `coffre_item.dart`.

### 💾 `storage/` (Persistance Hive)
- `story_record.dart` : Modèles de stockage pour Hive.
- `story_record.g.dart` : Adapters générés.

### 💾 `data/` (Sources de Données)
- `mock/` : Données de test (Simulations : stories, agenda, coffre, notes).

---
*Dernière mise à jour : 2024-04-28*

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
│   │   └── theme/
│   ├── data/
│   │   └── mock/
│   ├── models/
│   ├── screens/
│   │   ├── agenda/    ├── home/       ├── splash/
│   │   ├── atelier/   ├── onboarding/ ├── story/
│   │   ├── coffre/    ├── profil/     └── shell/
│   │   └── editor/
│   ├── state/
│   ├── storage/
│   ├── widgets/
│   │   ├── backgrounds/
│   │   ├── chips/
│   │   └── navigation/
│   ├── app.dart
│   └── main.dart
├── test/
└── pubspec.yaml
```

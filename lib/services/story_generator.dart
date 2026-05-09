import 'dart:math';
import '../models/assembled_block.dart';
import '../models/block_type.dart';

/// Service qui génère des amorces narratives à partir de blocs assemblés.
class StoryGenerator {
  static final _rand = Random();

  /// Cherche le bloc d'un type donné, retourne sa valeur ou un fallback.
  static String _val(
      List<AssembledBlock> blocks, BlockType type, String fallback) {
    final b = blocks.where((b) => b.type == type);
    if (b.isEmpty) return fallback;
    final v = b.first.value.trim();
    if (v.isEmpty || v.startsWith('(appuyer')) return fallback;
    return v;
  }

  /// Devine un genre/sous-titre en fonction du ton et des blocs présents.
  static String inferGenre(List<AssembledBlock> blocks) {
    final hasT = blocks.any((b) => b.type == BlockType.twist);
    final ton = _val(blocks, BlockType.ton, '').toLowerCase();
    if (ton.contains('sombre') || ton.contains('mélanco')) {
      return hasT ? 'Thriller psychologique' : 'Drame noir';
    }
    if (ton.contains('drôle') ||
        ton.contains('absurde') ||
        ton.contains('picaresque')) {
      return 'Comédie / Picaresque';
    }
    if (ton.contains('clinique') || ton.contains('glaç')) {
      return 'Sci-fi froide';
    }
    if (ton.contains('lumin')) {
      return 'Réalisme magique';
    }
    return 'Récit non défini';
  }

  /// Devine un titre court à partir des blocs sélectionnés.
  static String inferTitle(List<AssembledBlock> blocks) {
    final lieu = _val(blocks, BlockType.lieu, '');
    final perso = _val(blocks, BlockType.personnage, '');
    final conflit = _val(blocks, BlockType.conflit, '');

    if (lieu.isNotEmpty) {
      // Prend les 3 premiers mots du lieu
      final words = lieu.split(' ').take(3).join(' ');
      return 'Récit · $words';
    }
    if (perso.isNotEmpty) {
      final words = perso.split(',').first;
      return 'L\'histoire de $words';
    }
    if (conflit.isNotEmpty) {
      return conflit.split('.').first;
    }
    return 'Nouvelle Amorce';
  }

  /// Génère une amorce narrative en combinant les blocs assemblés.
  static String generate(List<AssembledBlock> blocks) {
    if (blocks.isEmpty) {
      return "Assemblez au moins deux blocs pour générer une amorce.";
    }

    final ton = _val(blocks, BlockType.ton, "une ambiance étrange");
    final perso =
        _val(blocks, BlockType.personnage, "un protagoniste mystérieux");
    final lieu = _val(blocks, BlockType.lieu, "un lieu indéfini");
    final conflit = _val(blocks, BlockType.conflit, "un conflit qui couve");
    final objectif =
        _val(blocks, BlockType.objectif, "une quête personnelle");
    final obstacle =
        _val(blocks, BlockType.obstacle, "des forces contraires");
    final twist = _val(blocks, BlockType.twist, "un retournement inattendu");
    final fin = _val(blocks, BlockType.fin, "une conclusion ouverte");

    final templates = <String>[
      "Dans $lieu, $perso se retrouve face à $conflit. "
          "L'atmosphère est $ton, et chaque pas le rapproche d'une vérité "
          "qu'il aurait préféré ne jamais découvrir. $twist.",
      "$perso n'avait jamais imaginé que $lieu deviendrait le théâtre de "
          "son histoire. Avec $ton pour seule boussole, il poursuit $objectif — "
          "mais $obstacle se dresse sur sa route.",
      "Tout commence à $lieu, par une nuit où $ton règne en maître. "
          "$perso doit affronter $conflit, ignorant encore que $twist.",
      "Imaginez : $lieu. Imaginez $perso. Imaginez $ton. "
          "Maintenant, ajoutez $conflit — et regardez l'histoire prendre vie, "
          "portée par $objectif et brisée par $obstacle. $fin.",
      "$perso a toujours fui $lieu. Mais aujourd'hui, $conflit l'y ramène. "
          "Dans cette atmosphère $ton, chaque décision pèse lourd. "
          "Et puis, sans prévenir, $twist.",
      "Il y a des histoires qui commencent par un lieu : $lieu. "
          "D'autres par un personnage : $perso. "
          "Celle-ci commence par $ton — et par $conflit qu'on ne peut plus ignorer.",
    ];

    return templates[_rand.nextInt(templates.length)];
  }
}

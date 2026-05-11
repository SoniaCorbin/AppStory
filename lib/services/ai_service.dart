import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/assembled_block.dart';
import '../models/block_type.dart';

/// Service pour appeler l'API Claude d'Anthropic.
class AiService {
  static const _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-sonnet-4-5';
  static const _apiVersion = '2023-06-01';
  static const _maxTokens = 1024;

  /// Génère une amorce narrative via l'API Claude.
  /// Throws en cas d'erreur réseau, clé invalide, etc.
  static Future<String> generateHook({
    required List<AssembledBlock> blocks,
    required String apiKey,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('Clé API manquante');
    }

    final prompt = _buildPrompt(blocks);

    final response = await http
        .post(
          Uri.parse(_apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': apiKey,
            'anthropic-version': _apiVersion,
          },
          body: jsonEncode({
            'model': _model,
            'max_tokens': _maxTokens,
            'messages': [
              {'role': 'user', 'content': prompt}
            ],
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      // Décode l'erreur si possible
      try {
        final body = jsonDecode(response.body);
        final errMsg = body['error']?['message'] ?? response.body;
        throw Exception('Claude API ${response.statusCode} : $errMsg');
      } catch (_) {
        throw Exception(
            'Claude API ${response.statusCode} : ${response.body}');
      }
    }

    final data = jsonDecode(response.body);
    final contentList = data['content'] as List?;
    if (contentList == null || contentList.isEmpty) {
      throw Exception('Réponse API vide');
    }
    final text = contentList.first['text'] as String?;
    if (text == null || text.isEmpty) {
      throw Exception('Pas de texte dans la réponse');
    }
    return text.trim();
  }

  /// Construit le prompt envoyé à Claude.
  static String _buildPrompt(List<AssembledBlock> blocks) {
    final buf = StringBuffer();
    buf.writeln(
        "Tu es un assistant créatif pour écrivains. Génère une amorce narrative en français, d'environ 80 à 130 mots, à partir des éléments suivants :");
    buf.writeln();

    for (final b in blocks) {
      final value = b.value.trim().isEmpty || b.value.contains('(appuyer')
          ? '(non précisé)'
          : b.value.trim();
      buf.writeln('- ${b.type.label} : $value');
    }

    buf.writeln();
    buf.writeln('CONSIGNES :');
    buf.writeln(
        '- Style littéraire, immersif, évocateur (3e personne ou 1re personne au choix)');
    buf.writeln('- Présent ou imparfait, comme dans un début de roman');
    buf.writeln('- Pas de titre, pas d\'introduction, pas de méta-commentaire');
    buf.writeln('- Réponds UNIQUEMENT par l\'amorce, en un seul paragraphe');

    return buf.toString();
  }
}

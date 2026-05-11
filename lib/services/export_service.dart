import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/block_type.dart';
import '../models/story.dart';

/// Service responsable de l'export des histoires en différents formats.
class ExportService {
  /// Génère le texte Markdown pour une histoire.
  static String toMarkdown(Story story) {
    final buffer = StringBuffer();

    // Titre
    buffer.writeln('# ${story.title}');
    buffer.writeln();

    // Métadonnées
    buffer.writeln('**Genre** : ${story.genre}  ');
    buffer.writeln('**Progression** : ${story.progress}%  ');
    buffer.writeln('**Dernière modif** : ${story.lastEdit}');
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();

    // Amorce
    if (story.hook.trim().isNotEmpty) {
      buffer.writeln('## ✦ Amorce narrative');
      buffer.writeln();
      buffer.writeln('> ${story.hook}');
      buffer.writeln();
    }

    // Blocs
    if (story.blocks.isNotEmpty) {
      buffer.writeln('## 🧱 Blocs narratifs');
      buffer.writeln();
      for (final b in story.blocks) {
        final value =
            b.value.trim().isEmpty ? '_(à définir)_' : b.value.trim();
        buffer.writeln('### ${b.type.icon} ${b.type.label}');
        buffer.writeln();
        buffer.writeln(value);
        buffer.writeln();
      }
    }

    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln(
        '_Généré depuis **StoryBlocks** — De l\'étincelle à l\'histoire ✦_');

    return buffer.toString();
  }

  /// Génère un PDF à partir d'une histoire et retourne les bytes.
  static Future<Uint8List> toPdfBytes(Story story) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return [
            // Titre
            pw.Text(
              story.title,
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),

            // Méta
            pw.Wrap(
              spacing: 12,
              children: [
                _pdfMeta('Genre', story.genre),
                _pdfMeta('Progression', '${story.progress}%'),
                _pdfMeta('Dernière modif', story.lastEdit),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColors.grey400),

            // Amorce
            if (story.hook.trim().isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Text('✦ AMORCE NARRATIVE',
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.deepPurple,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                  )),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border(
                    left: pw.BorderSide(
                        color: PdfColors.deepPurple, width: 3),
                  ),
                ),
                child: pw.Text(
                  story.hook,
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontStyle: pw.FontStyle.italic,
                    lineSpacing: 4,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
            ],

            // Blocs
            if (story.blocks.isNotEmpty) ...[
              pw.Text('BLOCS NARRATIFS',
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey700,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                  )),
              pw.SizedBox(height: 12),
              for (final b in story.blocks) ...[
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 12),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        b.type.label.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        b.value.trim().isEmpty ? '(à définir)' : b.value,
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            pw.SizedBox(height: 24),
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 8),
            pw.Text(
              'Généré depuis StoryBlocks — De l\'étincelle à l\'histoire',
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey600,
                fontStyle: pw.FontStyle.italic,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _pdfMeta(String label, String value) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text('$label : ',
            style: pw.TextStyle(
                fontSize: 11,
                color: PdfColors.grey700,
                fontWeight: pw.FontWeight.bold)),
        pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
      ],
    );
  }

  /// Sanitize un nom de fichier (vire les caractères dangereux).
  static String _safeName(String title) {
    final sanitized = title.replaceAll(RegExp(r'[^a-zA-Z0-9_\- àâäéèêëîïôöùûüç]'), '');
    return sanitized.replaceAll(' ', '_').toLowerCase();
  }

  /// Partage une histoire en Markdown via le menu natif.
  static Future<void> shareMarkdown(Story story) async {
    final md = toMarkdown(story);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${_safeName(story.title)}.md');
    await file.writeAsString(md);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/markdown', name: '${story.title}.md')],
      subject: story.title,
      text: 'Mon histoire « ${story.title} » créée avec StoryBlocks ✦',
    );
  }

  /// Partage une histoire en PDF via le menu natif.
  static Future<void> sharePdf(Story story) async {
    final bytes = await toPdfBytes(story);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${_safeName(story.title)}.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf', name: '${story.title}.pdf')],
      subject: story.title,
      text: 'Mon histoire « ${story.title} » créée avec StoryBlocks ✦',
    );
  }
}

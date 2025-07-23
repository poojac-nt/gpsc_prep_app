import 'dart:io';

import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfExportService {
  Future<String> exportQuestionsToPdf(
    List<QuestionLanguageData> questions,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build:
            (context) => [
              pw.Center(
                child: pw.Text(
                  "MCQ Solutions",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              ...questions.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final q = entry.value;

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Question $index:",
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    ..._parseMarkdownToPdfWidgets(q.questionTxt), // Improved!
                    pw.SizedBox(height: 5),
                    pw.Bullet(text: "A) ${q.optA}"),
                    pw.Bullet(text: "B) ${q.optB}"),
                    pw.Bullet(text: "C) ${q.optC}"),
                    pw.Bullet(text: "D) ${q.optD}"),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "Answer:",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      q.correctAnswer,
                      style: pw.TextStyle(
                        color: PdfColors.green,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Explanation:",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    ..._parseMarkdownToPdfWidgets(q.explanation), // Improved!
                    pw.Divider(),
                    pw.SizedBox(height: 10),
                  ],
                );
              }),
            ],
      ),
    );

    final outputDir =
        await getDownloadsDirectory() ?? await getTemporaryDirectory();
    final filePath =
        "${outputDir.path}/Test_Review_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  /// Platform-specific download directory
  Future<Directory?> getDownloadsDirectory() async {
    if (Platform.isAndroid) return Directory('/storage/emulated/0/Download');
    return await getApplicationDocumentsDirectory();
  }

  /// Robust Markdown parser to PDF widgets (supports: paragraph, bold, italic, heading, list, line breaks)
  List<pw.Widget> _parseMarkdownToPdfWidgets(String markdownText) {
    final document = md.Document(encodeHtml: false);
    final nodes = document.parseLines(markdownText.split('\n'));

    List<pw.Widget> widgets = [];
    for (var node in nodes) {
      widgets.addAll(_markdownNodeToPdfWidget(node));
    }
    return widgets;
  }

  List<pw.Widget> _markdownNodeToPdfWidget(md.Node node) {
    if (node is md.Element) {
      switch (node.tag) {
        case 'h1':
        case 'h2':
        case 'h3':
        case 'h4':
        case 'h5':
        case 'h6':
          final level = int.parse(node.tag.substring(1));
          return [
            pw.Text(
              node.textContent,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 18 - (level * 2),
              ),
            ),
            pw.SizedBox(height: 4),
          ];
        case 'ul':
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children:
                  node.children!
                      .expand((li) => _markdownNodeToPdfWidget(li))
                      .toList(),
            ),
          ];
        case 'ol':
          int i = 1;
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children:
                  node.children!
                      .map(
                        (li) => pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('$i. '),
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: _markdownNodeToPdfWidget(li),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
            ),
          ];
        case 'li':
          return [
            pw.Bullet(text: node.textContent),
            // works for simple list-items, for nested formatting you'll need recursion
          ];
        case 'p':
          return [
            _spanFromMarkdownInline(node.children ?? []),
            pw.SizedBox(height: 4),
          ];
        case 'strong':
        case 'em':
          // fallthrough: handled in _spanFromMarkdownInline
          return [
            _spanFromMarkdownInline([node]),
          ];
        case 'br':
          return [pw.SizedBox(height: 4)];
        default:
          // Unknown node: try rendering text content
          return [pw.Text(node.textContent)];
      }
    } else if (node is md.Text) {
      return [pw.Text(node.text)];
    }
    return [];
  }

  /// Inline markdown to pw.Text (handles **bold**, *italic* etc. within a paragraph)
  pw.Widget _spanFromMarkdownInline(List<md.Node> nodes) {
    return pw.RichText(
      text: pw.TextSpan(
        children:
            nodes.map((node) {
              if (node is md.Text) {
                return pw.TextSpan(text: node.text);
              } else if (node is md.Element) {
                final baseStyle = pw.TextStyle();
                if (node.tag == 'strong' || node.tag == 'b') {
                  return pw.TextSpan(
                    text: node.textContent,
                    style: baseStyle.copyWith(fontWeight: pw.FontWeight.bold),
                  );
                }
                if (node.tag == 'em' || node.tag == 'i') {
                  return pw.TextSpan(
                    text: node.textContent,
                    style: baseStyle.copyWith(fontStyle: pw.FontStyle.italic),
                  );
                }
                // For nested formatting inside paragraphs
                return pw.TextSpan(
                  children:
                      node.children?.map((e) {
                        if (e is md.Text) {
                          return pw.TextSpan(text: e.text);
                        } else if (e is md.Element) {
                          return pw.TextSpan(text: e.textContent);
                        }
                        return pw.TextSpan();
                      }).toList(),
                );
              }
              return pw.TextSpan();
            }).toList(),
      ),
    );
  }
}

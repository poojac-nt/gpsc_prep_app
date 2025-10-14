import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:media_store_plus/media_store_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

import '../../../domain/entities/question_language_model.dart';

class PdfExportService {
  Future<String> exportQuestionsToPdf(
    List<QuestionModel> questions,
    String testName,
  ) async {
    final log = getIt<LogHelper>();
    final mcqPdfHeader = pw.MemoryImage(
      (await rootBundle.load(
        'assets/images/mcq_pdf_header.jpeg',
      )).buffer.asUint8List(),
    );
    final telegramLogo = pw.MemoryImage(
      (await rootBundle.load(
        'assets/images/telegram_logo.png',
      )).buffer.asUint8List(),
    );
    final gmailLogo = pw.MemoryImage(
      (await rootBundle.load(
        'assets/images/gmail_logo.png',
      )).buffer.asUint8List(),
    );
    final xLogo = pw.MemoryImage(
      (await rootBundle.load('assets/images/x_logo.png')).buffer.asUint8List(),
    );
    final base = await rootBundle.load("assets/fonts/ArialUnicodeMs.otf");
    final baseFont = pw.Font.ttf(base);

    final imageProvider = PdfImage.file(
      pw.Document().document,
      bytes:
          (await rootBundle.load(
            'assets/images/mcq_pdf_header.jpeg',
          )).buffer.asUint8List(),
    );
    final imageHeight = imageProvider.height.toDouble();
    final imageWidth = imageProvider.width.toDouble();

    final pageWidth = PdfPageFormat.a4.width - 48; // minus 24 margin each side
    final scaledHeight = (imageHeight / imageWidth) * pageWidth;

    final pdf = pw.Document(
      pageMode: PdfPageMode.fullscreen,
      theme: pw.ThemeData.withFont(
        base: baseFont,
        fontFallback: [baseFont, pw.Font.symbol()],
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        footer:
            (context) => pw.Container(
              alignment: pw.Alignment.center,
              margin: const pw.EdgeInsets.only(top: 10),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  pw.Text(
                    'Click here to Join us:',
                    style: pw.TextStyle(
                      fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Row(
                    children: [
                      pw.Image(telegramLogo, width: 10, height: 10),
                      pw.SizedBox(width: 4),
                      pw.UrlLink(
                        destination: 'https://t.me/starics_prep',
                        child: pw.Text(
                          '@starics_prep',
                          style: pw.TextStyle(
                            color: PdfColors.blue,
                            decoration: pw.TextDecoration.underline,
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Text('|', style: pw.TextStyle(fontSize: 9.5)),
                  pw.Row(
                    children: [
                      pw.Image(gmailLogo, width: 10, height: 10),
                      pw.SizedBox(width: 4),
                      pw.UrlLink(
                        destination: 'mailto:star.ics89@gmail.com',
                        child: pw.Text(
                          'star.ics89@gmail.com',
                          style: pw.TextStyle(
                            color: PdfColors.blue,
                            decoration: pw.TextDecoration.underline,
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Text('|', style: pw.TextStyle(fontSize: 9.5)),
                  pw.Row(
                    children: [
                      pw.Image(xLogo, width: 10, height: 10),
                      pw.SizedBox(width: 4),
                      pw.UrlLink(
                        destination: 'https://x.com/star_ics89',
                        child: pw.Text(
                          '@star_ics89',
                          style: pw.TextStyle(
                            color: PdfColors.blue,
                            decoration: pw.TextDecoration.underline,
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        build:
            (context) => [
              pw.Container(
                height: scaledHeight,
                child: pw.Stack(
                  fit: pw.StackFit.expand,
                  children: [
                    pw.Image(mcqPdfHeader, fit: pw.BoxFit.cover),
                    pw.Positioned(
                      left: 40,
                      top: scaledHeight * 0.5 - 10,
                      child: pw.Container(
                        width: 250,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Divider(
                              indent: 0,
                              color: PdfColor.fromHex('#d8b7b2'),
                              thickness: 5,
                              height: 5,
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.symmetric(vertical: 10),
                              child: pw.Text(
                                testName,
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Divider(
                              indent: 0,
                              color: PdfColor.fromHex('#d8b7b2'),
                              thickness: 5,
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...questions.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final ln =
                    getIt<CacheManager>()
                        .userSelectedLanguage(); // e.g., "en", "hi", "gj"
                QuestionLanguageData getLangData(QuestionModel q) {
                  switch (ln) {
                    case 'hi':
                      return q.questionHi ?? q.questionEn;
                    case 'gj':
                      return q.questionGj ?? q.questionEn;
                    case 'en':
                    default:
                      return q.questionEn;
                  }
                }

                final q = entry.value;

                final qLang = getLangData(q);

                return pw.Padding(
                  padding: pw.EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  child: pw.Column(
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
                      ..._parseMarkdownToPdfWidgets(qLang.questionTxt),
                      pw.SizedBox(height: 5),
                      pw.Bullet(text: qLang.optA),
                      pw.Bullet(text: qLang.optB),
                      pw.Bullet(text: qLang.optC),
                      pw.Bullet(text: qLang.optD),
                      pw.SizedBox(height: 5),
                      pw.Container(
                        padding: pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#e1d2c8'),
                          border: pw.Border.all(
                            color: PdfColors.black,
                            width: 1,
                          ),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.RichText(
                              text: pw.TextSpan(
                                text: "Answer: ",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                children: [
                                  pw.TextSpan(
                                    text: qLang.correctAnswer,
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.RichText(
                              text: pw.TextSpan(
                                text: "Difficulty Level: ",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                children: [
                                  pw.TextSpan(text: q.difficultyLevel.level),
                                ],
                              ),
                            ),
                            pw.RichText(
                              text: pw.TextSpan(
                                text: "Subject: ",
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                children: [pw.TextSpan(text: q.subjectName)],
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              "Explanation:",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            ..._parseMarkdownToPdfWidgets(qLang.explanation),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
      ),
    );

    // Generate PDF bytes
    final pdfBytes = await pdf.save();
    final filename = "${testName.toSafeFileName()}.pdf";

    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        // ✅ Scoped Storage path (API 29+)
        if (sdkInt >= 29) {
          final permission = await Permission.storage.request();
          if (!permission.isGranted) {
            throw Exception("Storage permission not granted");
          }

          final tempDir = await getTemporaryDirectory();
          final tempPath = "${tempDir.path}/$filename";
          final tempFile = File(tempPath);
          await tempFile.writeAsBytes(pdfBytes);

          final mediaStore = MediaStore();
          MediaStore.appFolder = "StarICS";

          final saveInfo = await mediaStore.saveFile(
            tempFilePath: tempPath,
            dirType: DirType.download,
            dirName: DirName.download,
            relativePath: "StarICS/",
          );

          if (saveInfo == null) {
            throw Exception("Failed to save PDF to MediaStore");
          }

          final uri = saveInfo.uri.toString(); // content://...
          log.i("Saved file URI: $uri");

          String? realPath;
          try {
            realPath = await MediaStore().getFilePathFromUri(uriString: uri);
            log.i("Resolved real path: $realPath");
          } catch (e) {
            log.e("Could not resolve path from URI: $e");
          }

          if (realPath != null) {
            final openResult = await OpenFilex.open(realPath);
            log.i("OpenFilex: ${openResult.message}");
            return realPath;
          } else {
            // If path resolution fails, try opening via URI (if some plugin supports it),
            // or fallback to tempFile.
            final openResult = await OpenFilex.open(uri);
            log.i("Tried opening via URI: ${openResult.message}");
            return uri;
          }
        }
      }

      // ✅ iOS or Android < 10 fallback
      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/$filename";
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      log.i("PDF saved locally: $filePath");
      await OpenFilex.open(filePath);
      return filePath;
    } catch (e) {
      log.e("Error exporting PDF: $e");

      // Safe fallback – still return a readable path
      final fallbackDir = await getTemporaryDirectory();
      final fallbackPath = "${fallbackDir.path}/$filename";
      await File(fallbackPath).writeAsBytes(pdfBytes);
      return fallbackPath;
    }
  }

  /// Platform-specific download directory
  Future<Directory?> getDownloadsDirectory() async {
    if (Platform.isAndroid) return Directory('/storage/emulated/0/Download');
    return await getApplicationDocumentsDirectory();
  }

  /// Robust Markdown parser to PDF widgets (supports: paragraph, bold, italic, heading, list, line breaks)
  List<pw.Widget> _parseMarkdownToPdfWidgets(String markdownText) {
    final lines = markdownText.split('\n');

    List<pw.Widget> widgets = [];
    int i = 0;

    while (i < lines.length) {
      if (lines[i].trim().startsWith('|') &&
          i + 2 < lines.length &&
          lines[i + 1].contains('---')) {
        List<String> tableLines = [];

        while (i < lines.length && lines[i].trim().startsWith('|')) {
          tableLines.add(lines[i]);
          i++;
        }

        widgets.add(_buildPdfTableFromMarkdown(tableLines));
        widgets.add(pw.SizedBox(height: 8));
      } else {
        final buffer = StringBuffer();
        while (i < lines.length && !lines[i].trim().startsWith('|')) {
          buffer.writeln(lines[i]);
          i++;
        }
        final normalMd = buffer.toString().trim();
        if (normalMd.isNotEmpty) {
          final document = md.Document(encodeHtml: false);
          final nodes = document.parseLines(normalMd.split('\n'));
          for (var node in nodes) {
            widgets.addAll(_markdownNodeToPdfWidget(node));
          }
        }
      }
    }

    return widgets;
  }

  pw.Widget _buildPdfTableFromMarkdown(List<String> tableLines) {
    List<List<String>> rows =
        tableLines
            .map(
              (line) =>
                  line
                      .trim()
                      .split('|')
                      .map((cell) => cell.trim())
                      .where((cell) => cell.isNotEmpty)
                      .toList(),
            )
            .toList();

    if (rows.length < 2) return pw.SizedBox(); // Not a valid table

    final header = rows[0];
    final dataRows = rows.sublist(2);

    return pw.TableHelper.fromTextArray(
      headers: header,
      data: dataRows,
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(4),
    );
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
          return [pw.Bullet(text: node.textContent)];
        case 'p':
          return [
            _spanFromMarkdownInline(node.children ?? []),
            pw.SizedBox(height: 4),
          ];
        case 'strong':
        case 'em':
          return [
            _spanFromMarkdownInline([node]),
          ];
        case 'br':
          return [pw.SizedBox(height: 4)];
        default:
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

extension SafeFileName on String {
  String toSafeFileName() {
    return replaceAll('/', '-');
  }
}

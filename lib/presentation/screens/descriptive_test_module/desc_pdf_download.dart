import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/domain/entities/desc_question_model.dart';
import 'package:gpsc_prep_app/presentation/screens/preview_screen/pdf_export_service.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:media_store_plus/media_store_plus.dart';
import 'package:open_file_manager/open_file_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<String> generateDescTestPdf(
  DescQuestionModel question,
  int index,
  String testName,
) async {
  final base = await rootBundle.load("assets/fonts/ArialUnicodeMs.otf");
  final baseFont = pw.Font.ttf(base);

  final pdf = pw.Document(
    pageMode: PdfPageMode.fullscreen,
    theme: pw.ThemeData.withFont(
      base: baseFont,
      fontFallback: [baseFont, pw.Font.symbol()],
    ),
  );

  // Load logo
  final logoData = await rootBundle.load('assets/images/logo_without_bg.png');
  final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

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

  pw.Widget borderedPage(pw.Widget child) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      padding: const pw.EdgeInsets.all(16),
      child: child,
    );
  }

  // --- Page 1 ---
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return borderedPage(
          pw.Stack(
            children: [
              pw.Center(
                child: pw.Opacity(
                  opacity: 0.1,
                  child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Question $index",
                    style: pw.TextStyle(
                      fontSize: 12.sp,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  ..._parseMarkdownToPdfWidgets(
                    question.questionEn.questionTxt,
                  ),
                  if (question.questionHi?.questionTxt != null &&
                      question.questionHi!.questionTxt.isNotEmpty) ...[
                    pw.SizedBox(height: 10),
                    ..._parseMarkdownToPdfWidgets(
                      question.questionHi!.questionTxt,
                    ),
                  ],
                  if (question.questionGj?.questionTxt != null &&
                      question.questionGj!.questionTxt.isNotEmpty) ...[
                    pw.SizedBox(height: 10),
                    ..._parseMarkdownToPdfWidgets(
                      question.questionGj!.questionTxt,
                    ),
                  ],
                ],
              ),
              // --- Footer ---
              pw.Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: pw.Container(
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
              ),
            ],
          ),
        );
      },
    ),
  );

  // --- Extra pages ---
  for (int i = 1; i < (question.pages ?? 1); i++) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return borderedPage(
            pw.Stack(
              children: [
                pw.Center(
                  child: pw.Opacity(
                    opacity: 0.1,
                    child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                  ),
                ),
                // Footer reused
                pw.Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: pw.Container(
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Save PDF ---
  final bytes = await pdf.save();
  final safeFileName = "${testName.toSafeFileName()}_Question$index.pdf";
  String filePath;

  try {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // ✅ Android 10+ (Scoped Storage)
      if (sdkInt >= 29) {
        final tempDir = await getTemporaryDirectory();
        final tempPath = "${tempDir.path}/$safeFileName";
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(bytes);

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

        String? realPath;
        try {
          realPath = await mediaStore.getFilePathFromUri(
            uriString: saveInfo.uri.toString(),
          );
        } catch (e) {
          getIt<LogHelper>().e("Could not resolve file path: $e");
        }

        if (realPath != null && await File(realPath).exists()) {
          filePath = realPath;
          await openFileManager(
            androidConfig: AndroidConfig(
              folderPath: realPath,
              folderType: AndroidFolderType.download,
            ),
          );
        } else {
          filePath = saveInfo.uri.toString();
          await openFileManager(
            androidConfig: AndroidConfig(
              folderPath: filePath,
              folderType: AndroidFolderType.download,
            ),
          );
        }
        return filePath;
      } else {
        // ✅ Android 9 and below – direct /Download/StarICS
        final downloadsDir = Directory("/storage/emulated/0/Download/StarICS");
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        filePath = "${downloadsDir.path}/$safeFileName";
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        await openFileManager(
          androidConfig: AndroidConfig(
            folderPath: filePath,
            folderType: AndroidFolderType.download,
          ),
        );
        return filePath;
      }
    } else {
      // ✅ iOS or other platforms
      final dir = await getApplicationDocumentsDirectory();
      filePath = "${dir.path}/$safeFileName";
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      await openFileManager(
        androidConfig: AndroidConfig(
          folderPath: filePath,
          folderType: AndroidFolderType.download,
        ),
      );
      return filePath;
    }
  } catch (e) {
    getIt<LogHelper>().e("Error generating Desc PDF: $e");
    final fallbackDir = await getTemporaryDirectory();
    filePath = "${fallbackDir.path}/$safeFileName";
    await File(filePath).writeAsBytes(bytes);
    return filePath;
  }
}

Future<String> generateFullDescTestPdf(
  List<DescQuestionModel> questions,
  String testName,
) async {
  final base = await rootBundle.load("assets/fonts/ArialUnicodeMs.otf");
  final baseFont = pw.Font.ttf(base);

  final pdf = pw.Document(
    pageMode: PdfPageMode.fullscreen,
    theme: pw.ThemeData.withFont(
      base: baseFont,
      fontFallback: [baseFont, pw.Font.symbol()],
    ),
  );

  // Load logo
  final logoData = await rootBundle.load('assets/images/logo_without_bg.png');
  final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

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

  pw.Widget borderedPage(pw.Widget child) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      padding: const pw.EdgeInsets.all(16),
      child: child,
    );
  }

  pw.Widget buildFooter() {
    return pw.Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: pw.Container(
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
    );
  }

  for (int i = 0; i < questions.length; i++) {
    final question = questions[i];
    final index = i + 1;

    // --- Page 1 ---
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return borderedPage(
            pw.Stack(
              children: [
                pw.Center(
                  child: pw.Opacity(
                    opacity: 0.1,
                    child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Question $index",
                      style: pw.TextStyle(
                        fontSize: 12.sp,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    ..._parseMarkdownToPdfWidgets(
                      question.questionEn.questionTxt,
                    ),
                    if (question.questionHi?.questionTxt != null &&
                        question.questionHi!.questionTxt.isNotEmpty) ...[
                      pw.SizedBox(height: 10),
                      ..._parseMarkdownToPdfWidgets(
                        question.questionHi!.questionTxt,
                      ),
                    ],
                    if (question.questionGj?.questionTxt != null &&
                        question.questionGj!.questionTxt.isNotEmpty) ...[
                      pw.SizedBox(height: 10),
                      ..._parseMarkdownToPdfWidgets(
                        question.questionGj!.questionTxt,
                      ),
                    ],
                  ],
                ),
                buildFooter(),
              ],
            ),
          );
        },
      ),
    );

    // --- Extra pages ---
    for (int j = 1; j < (question.pages ?? 1); j++) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return borderedPage(
              pw.Stack(
                children: [
                  pw.Center(
                    child: pw.Opacity(
                      opacity: 0.1,
                      child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                    ),
                  ),
                  buildFooter(),
                ],
              ),
            );
          },
        ),
      );
    }
  }

  // --- Save PDF ---
  final bytes = await pdf.save();
  final safeFileName = "${testName.toSafeFileName()}_FullTest.pdf";
  String filePath;

  try {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // ✅ Android 10+ (Scoped Storage)
      if (sdkInt >= 29) {
        final tempDir = await getTemporaryDirectory();
        final tempPath = "${tempDir.path}/$safeFileName";
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(bytes);

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

        String? realPath;
        try {
          realPath = await mediaStore.getFilePathFromUri(
            uriString: saveInfo.uri.toString(),
          );
        } catch (e) {
          getIt<LogHelper>().e("Could not resolve file path: $e");
        }

        if (realPath != null && await File(realPath).exists()) {
          filePath = realPath;
          await openFileManager(
            androidConfig: AndroidConfig(
              folderPath: realPath,
              folderType: AndroidFolderType.download,
            ),
          );
        } else {
          filePath = saveInfo.uri.toString();
          await openFileManager(
            androidConfig: AndroidConfig(
              folderPath: filePath,
              folderType: AndroidFolderType.download,
            ),
          );
        }
        return filePath;
      } else {
        // ✅ Android 9 and below – direct /Download/StarICS
        final downloadsDir = Directory("/storage/emulated/0/Download/StarICS");
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        filePath = "${downloadsDir.path}/$safeFileName";
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        await openFileManager(
          androidConfig: AndroidConfig(
            folderPath: filePath,
            folderType: AndroidFolderType.download,
          ),
        );
        return filePath;
      }
    } else {
      // ✅ iOS or other platforms
      final dir = await getApplicationDocumentsDirectory();
      filePath = "${dir.path}/$safeFileName";
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      await openFileManager(
        androidConfig: AndroidConfig(
          folderPath: filePath,
          folderType: AndroidFolderType.download,
        ),
      );
      return filePath;
    }
  } catch (e) {
    getIt<LogHelper>().e("Error generating full Desc PDF: $e");
    final fallbackDir = await getTemporaryDirectory();
    filePath = "${fallbackDir.path}/$safeFileName";
    await File(filePath).writeAsBytes(bytes);
    return filePath;
  }
}

/// --- Markdown Parsing Helpers (unchanged) ---
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

  if (rows.length < 2) return pw.SizedBox();
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

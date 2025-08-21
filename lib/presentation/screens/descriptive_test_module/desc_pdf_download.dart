import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:gpsc_prep_app/domain/entities/desc_question_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<String> generateDescTestPdf(
  DescQuestionModel question,
  int index,
  String testName,
) async {
  final pdf = pw.Document();

  // Load logo
  final logoData = await rootBundle.load('assets/images/logo_without_bg.png');
  final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

  // --- Helper to wrap content with border ---
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
                    "Q1 ${question.questionEn.questionTxt}",
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  if (question.questionHi?.questionTxt != null &&
                      question.questionHi!.questionTxt.isNotEmpty) ...[
                    pw.SizedBox(height: 10),
                    pw.Text(question.questionHi!.questionTxt),
                  ],
                  if (question.questionGj?.questionTxt != null &&
                      question.questionGj!.questionTxt.isNotEmpty) ...[
                    pw.SizedBox(height: 10),
                    pw.Text(question.questionGj!.questionTxt),
                  ],
                ],
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
            pw.Center(
              child: pw.Opacity(
                opacity: 0.1,
                child: pw.Image(logoImage, fit: pw.BoxFit.contain),
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ Save in Downloads (Android), sandbox (iOS)
  String filePath;
  if (Platform.isAndroid) {
    final downloadsDir = Directory("/storage/emulated/0/Download");
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    filePath = "${downloadsDir.path}/${testName}_Question$index.pdf";
  } else {
    final dir = await getApplicationDocumentsDirectory();
    filePath = "${dir.path}/${testName}_Question$index.pdf";
  }

  final file = File(filePath);
  await file.writeAsBytes(await pdf.save());

  return file.path;
}

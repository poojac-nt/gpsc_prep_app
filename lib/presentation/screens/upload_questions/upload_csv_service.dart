import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadResult {
  final int successCount;
  final int failCount;
  final int duplicateCount;

  UploadResult({
    required this.successCount,
    required this.failCount,
    required this.duplicateCount,
  });
}

Future<UploadResult> uploadCsvAndInsertQuestions() async {
  // Let user pick a file
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv', 'xlsx'],
  );

  if (result == null || result.files.isEmpty) {
    print('❗ No file selected.');
    return UploadResult(successCount: 0, failCount: 0, duplicateCount: 0);
  }

  final file = result.files.first;
  final filePath = file.path;

  if (filePath == null) {
    print('❗ File path is null.');
    return UploadResult(successCount: 0, failCount: 0, duplicateCount: 0);
  }

  List<List<dynamic>> rows = [];

  // Handle CSV
  if (file.extension == 'csv') {
    final content = await File(filePath).readAsString();
    rows = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(content);
  }
  // Handle XLSX
  else if (file.extension == 'xlsx') {
    final bytes = File(filePath).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    // Assumes first sheet
    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null || sheet.rows.isEmpty) {
      print('❗ XLSX file is empty.');
      return UploadResult(successCount: 0, failCount: 0, duplicateCount: 0);
    }

    rows =
        sheet.rows
            .map((row) => row.map((e) => e?.value.toString() ?? '').toList())
            .toList();
  } else {
    print('❗ Unsupported file type.');
    return UploadResult(successCount: 0, failCount: 0, duplicateCount: 0);
  }

  if (rows.isEmpty) {
    print('❗ No data found in the file.');
    return UploadResult(successCount: 0, failCount: 0, duplicateCount: 0);
  }

  // Normalize headers
  final rawHeader = rows.first;
  final header =
      rawHeader.map((e) => e.toString().toLowerCase().trim()).toList();
  final dataRows = rows.skip(1);

  // Required headers
  const requiredHeaders = [
    'question_text',
    'question_type',
    'difficulty_level',
    'topic_name',
    'subject_name',
    'option_a',
    'option_b',
    'option_c',
    'option_d',
    'correct_answer',
  ];

  final missingHeaders =
      requiredHeaders.where((h) => !header.contains(h)).toList();
  if (missingHeaders.isNotEmpty) {
    print('❗ Missing required headers: $missingHeaders');
    return UploadResult(successCount: 0, failCount: 0, duplicateCount: 0);
  }

  final supabase = Supabase.instance.client;

  // Fetch existing questions
  final existingQuestionsRes = await supabase
      .from('questions')
      .select('question_text');

  final existingQuestions =
      (existingQuestionsRes as List)
          .map((q) => (q['question_text'] as String).toLowerCase().trim())
          .toSet();

  int successCount = 0;
  int failCount = 0;
  int duplicateCount = 0;

  for (final row in dataRows) {
    if (row.length < header.length) continue;

    final Map<String, dynamic> rowData = {};
    for (int i = 0; i < header.length; i++) {
      final key = header[i];
      rowData[key] = row[i]?.toString().trim();
    }

    final incomingQuestionText =
        (rowData['question_text'] ?? '').toLowerCase().trim();

    if (existingQuestions.contains(incomingQuestionText)) {
      print('⚠️ Duplicate skipped: $incomingQuestionText');
      duplicateCount++;
      continue;
    }

    print('➡️ Inserting: $incomingQuestionText');

    try {
      final result = await supabase.rpc<String>(
        'insert_question_data',
        params: {
          'p_question_type': rowData['question_type'],
          'p_question_text': rowData['question_text'],
          'p_difficulty_level': rowData['difficulty_level'],
          'p_topic_name': rowData['topic_name'],
          'p_subject_name': rowData['subject_name'],
          'p_option_a': rowData['option_a'],
          'p_option_b': rowData['option_b'],
          'p_option_c': rowData['option_c'],
          'p_option_d': rowData['option_d'],
          'p_correct_answer': rowData['correct_answer'],
        },
      );

      print('✅ Inserted: $result');
      successCount++;
    } catch (e) {
      print('❌ Failed to insert: ${rowData['question_text']}');
      print('   ↳ Error: $e');
      failCount++;
    }
  }

  print(
    '\n🧾 Upload Summary: '
    '✅ Success: $successCount | '
    '❌ Failed: $failCount | '
    '♻️ Duplicates: $duplicateCount\n',
  );

  return UploadResult(
    successCount: successCount,
    failCount: failCount,
    duplicateCount: duplicateCount,
  );
}

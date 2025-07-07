import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _log = getIt<LogHelper>();

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

Future<UploadResult?> uploadCsvOrXlsxToSupabaseMobile() async {
  try {
    final pickedFileResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
      withData: true,
    );

    if (pickedFileResult == null ||
        pickedFileResult.files.single.bytes == null) {
      throw Exception('Upload cancelled or file unreadable.');
    }

    final file = pickedFileResult.files.single;
    final ext = file.extension?.toLowerCase();
    late List<List<dynamic>> rows;

    // CSV or XLSX
    if (ext == 'csv') {
      String content = utf8
          .decode(file.bytes!)
          .replaceFirst(RegExp(r'^\ufeff'), '');
      rows = const CsvToListConverter().convert(
        content,
        eol: '\n',
        shouldParseNumbers: false,
      );
    } else if (ext == 'xlsx') {
      final excel = Excel.decodeBytes(file.bytes!);
      final sheet = excel.tables.values.first;
      rows =
          sheet.rows
              .map(
                (row) =>
                    row.map((cell) => cell?.value?.toString() ?? '').toList(),
              )
              .toList();
    } else {
      throw Exception('Unsupported file format');
    }

    if (rows.isEmpty) throw Exception('The file is empty.');

    final headers =
        rows.first
            .map(
              (h) =>
                  h
                      .toString()
                      .replaceFirst(RegExp(r'^\ufeff'), '')
                      .trim()
                      .toLowerCase(),
            )
            .toList();

    final requiredHeaders = {
      'sr_no',
      'language_code',
      'question_type',
      'difficulty_level',
      'subject_name',
      'topic_name',
      'question_text',
      'option_a',
      'option_b',
      'option_c',
      'option_d',
      'correct_answer',
      'explanation',
    };

    final missingHeaders = requiredHeaders.difference(headers.toSet());
    if (missingHeaders.isNotEmpty) {
      throw Exception(
        'Missing required column(s): ${missingHeaders.join(', ')}',
      );
    }

    final dataRows = rows.skip(1);
    final Map<String, Map<String, dynamic>> grouped = {};
    int rowIndex = 1;

    for (final row in dataRows) {
      rowIndex++;

      if (row.every(
        (field) => field == null || field.toString().trim().isEmpty,
      )) {
        continue;
      }

      final rowMap = Map.fromIterables(headers, row);

      for (final key in requiredHeaders) {
        final value = rowMap[key]?.toString().trim();
        if (value == null || value.isEmpty) {
          throw Exception(
            'Missing value for "$key" in row $rowIndex (sr_no: ${rowMap['sr_no'] ?? 'unknown'})',
          );
        }
      }

      final srNo = rowMap['sr_no']!;
      final lang = rowMap['language_code']!;
      final langData = {
        "question_txt": rowMap['question_text'],
        "opt_a": rowMap['option_a'],
        "opt_b": rowMap['option_b'],
        "opt_c": rowMap['option_c'],
        "opt_d": rowMap['option_d'],
        "correct_answer": rowMap['correct_answer'],
        "explanation": rowMap['explanation'],
      };

      grouped.putIfAbsent(
        srNo,
        () => {
          "question_type": rowMap['question_type'],
          "difficulty_level": rowMap['difficulty_level'],
          "subject_name": rowMap['subject_name'],
          "topic_name": rowMap['topic_name'],
          "languages": {},
        },
      );

      grouped[srNo]!['languages'][lang] = langData;
    }

    if (grouped.isEmpty) {
      throw Exception('No valid data found after validation.');
    }

    final payload = grouped.values.toList();

    final rpcResult = await Supabase.instance.client.rpc(
      'insert_multilingual_questions',
      params: {'payload': payload},
    );

    final response = rpcResult as Map<String, dynamic>;
    return UploadResult(
      successCount: response['inserted'] ?? 0,
      failCount: response['failed'] ?? 0,
      duplicateCount: response['skipped_duplicates'] ?? 0,
    );
  } catch (e) {
    // Optionally log error or show toast
    _log.e('❌ Upload failed: $e');
    return null;
  }
}

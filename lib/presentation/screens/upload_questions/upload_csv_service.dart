import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/utils/constants/supabase_keys.dart';

final _log = getIt<LogHelper>();
final _supabase = getIt<SupabaseHelper>().supabase;
final _snackBar = getIt<SnackBarHelper>();

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
    _log.i('Starting file pick...');
    final pickedFileResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
      withData: false,
    );

    if (pickedFileResult == null || pickedFileResult.files.isEmpty) {
      _log.w('File pick cancelled or no files selected.');
      throw Exception('Upload cancelled by user.');
    }

    final file = pickedFileResult.files.single;
    final filePath = file.path;
    _log.i('Picked file: ${file.name}, path: $filePath');

    if (filePath == null) {
      _log.e('File path is null.');
      throw Exception('File path is null.');
    }

    final ext = file.extension?.toLowerCase();
    _log.i('File extension: $ext');
    late List<List<dynamic>> rows;

    if (ext == 'csv') {
      _log.i('Reading CSV file...');
      final content = await File(filePath).readAsString();
      final cleaned = content.replaceFirst(RegExp(r'^\ufeff'), '');
      rows = const CsvToListConverter().convert(
        cleaned,
        eol: '\n',
        shouldParseNumbers: false,
      );
      _log.i('CSV parsed, rows: ${rows.length}');
    } else if (ext == 'xlsx') {
      _log.i('Reading XLSX file...');
      final bytes = await File(filePath).readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet =
          excel.tables.values.isNotEmpty ? excel.tables.values.first : null;
      if (sheet == null || sheet.rows.isEmpty) {
        _log.e('Excel file has no data.');
        throw Exception('Excel file has no data.');
      }
      rows =
          sheet.rows
              .map(
                (row) =>
                    row.map((cell) => cell?.value?.toString() ?? '').toList(),
              )
              .toList();
      _log.i('XLSX parsed, rows: ${rows.length}');
    } else {
      _log.e('Unsupported file format: $ext');
      _snackBar.showError('Unsupported file format');
      return null;
    }

    if (rows.isEmpty) {
      _log.e('File is empty after parsing.');
      _snackBar.showError('The file is empty.');
      return null;
    }

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
    _log.i('Parsed headers: $headers');

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
      'marks',
    };
    final missingHeaders = requiredHeaders.difference(headers.toSet());
    if (missingHeaders.isNotEmpty) {
      _log.e('Missing required columns: $missingHeaders');
      _snackBar.showError(
        'Missing required column(s): ${missingHeaders.join(', ')}',
      );
      return null;
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
          _log.e(
            'Missing value for "$key" in row $rowIndex (sr_no: ${rowMap['sr_no'] ?? 'unknown'})',
          );
          _snackBar.showError(
            'Missing value for "$key" in row $rowIndex (sr_no: ${rowMap['sr_no'] ?? 'unknown'})',
          );
          return null;
        }
      }
      final srNo = rowMap['sr_no'];
      final lang = rowMap['language_code'];
      if (srNo == null || lang == null) {
        _log.e('Null sr_no or language_code in row $rowIndex');
        continue; // Or return null, depending on your needs
      }
      final langData = {
        "question_txt": rowMap['question_text'],
        "opt_a": rowMap['option_a'],
        "opt_b": rowMap['option_b'],
        "opt_c": rowMap['option_c'],
        "opt_d": rowMap['option_d'],
        "correct_answer": rowMap['correct_answer'],
        "explanation": rowMap['explanation'],
      };
      grouped.putIfAbsent(srNo, () {
        final base = {
          "question_type": rowMap['question_type'],
          "difficulty_level": rowMap['difficulty_level'],
          "subject_name": rowMap['subject_name'],
          "topic_name": rowMap['topic_name'],
          "marks": int.tryParse(rowMap['marks'].toString()) ?? 1,
          "languages": <String, dynamic>{},
        };
        if (headers.contains('test_name') &&
            rowMap['test_name']?.toString().trim().isNotEmpty == true) {
          base['test_name'] = rowMap['test_name'];
        }
        if (headers.contains('duration') &&
            rowMap['duration']?.toString().trim().isNotEmpty == true) {
          base['duration'] = int.tryParse(rowMap['duration'].toString()) ?? 1;
        }
        return base;
      });
      final existing = grouped[srNo]!;
      if (existing['subject_name'] != rowMap['subject_name'] ||
          existing['topic_name'] != rowMap['topic_name'] ||
          existing['question_type'] != rowMap['question_type']) {
        _log.e('Conflicting metadata for sr_no $srNo at row $rowIndex');
        _snackBar.showError(
          'Conflicting metadata for sr_no $srNo at row $rowIndex: subject/topic/question_type mismatch',
        );
        return null;
      }
      grouped[srNo]!['languages'][lang] = langData;
    }

    if (grouped.isEmpty) {
      _log.e('No valid data found after validation.');
      return null;
    }

    final payload = grouped.values.toList();
    _log.i('Prepared payload for Supabase: ${payload.length} items');

    final rpcResult = await _supabase.rpc(
      SupabaseKeys.insertMcqWithTest2,
      params: {'payload': payload},
    );
    _log.i('Received RPC result: $rpcResult');

    final response = rpcResult as Map<String, dynamic>?;
    if (response == null) {
      _log.e('RPC response is null.');
      return null;
    }

    return UploadResult(
      successCount: response['inserted'] ?? 0,
      failCount: response['failed'] ?? 0,
      duplicateCount: response['skipped_duplicates'] ?? 0,
    );
  } catch (e, stack) {
    _log.e('❌ Upload failed: $e\n$stack');
    return null;
  }
}

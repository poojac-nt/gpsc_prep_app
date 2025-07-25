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

Future<UploadResult?> uploadCsvOrXlsxToSupabaseMobile({
  required bool isTestUpload,
}) async {
  try {
    final pickedFileResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
      withData: false,
    );

    if (pickedFileResult == null || pickedFileResult.files.isEmpty) {
      _snackBar.showError('Upload cancelled by user.');
      return null;
    }

    final file = pickedFileResult.files.single;
    final filePath = file.path;
    if (filePath == null) throw Exception('File path is null.');

    late List<List<dynamic>> rows;
    final ext = file.extension?.toLowerCase();

    if (ext == 'csv') {
      final content = await File(filePath).readAsString();
      rows = const CsvToListConverter().convert(
        content.replaceFirst(RegExp(r'^\ufeff'), ''),
        eol: '\n',
        shouldParseNumbers: false,
      );
    } else if (ext == 'xlsx') {
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
    } else {
      _snackBar.showError('Unsupported file format');
      return null;
    }

    if (rows.isEmpty) {
      _snackBar.showError('The file is empty.');
      return null;
    }

    final headers =
        rows.first.map((h) => h.toString().trim().toLowerCase()).toList();
    final dataRows = rows.skip(1).toList();
    if (dataRows.isEmpty) {
      _snackBar.showError('No data rows found.');
      return null;
    }

    final descRequiredHeaders = {
      'sr_no',
      'language_code',
      'question_type',
      'difficulty_level',
      'subject_name',
      'topic_name',
      'question_text',
      'marks',
    };

    final otherRequiredHeaders = {
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

    final firstRowMap = Map.fromIterables(
      headers,
      dataRows.first.map((e) => e.toString().trim()),
    );
    final firstTestName = firstRowMap['test_name'] ?? '';
    final firstTestType = firstRowMap['test_type'] ?? '';
    final firstDuration = firstRowMap['duration'] ?? '';

    if (isTestUpload) {
      if (firstTestName.isEmpty ||
          firstTestType.isEmpty ||
          firstDuration.isEmpty) {
        _snackBar.showError(
          'Test upload requires test_name, test_type, and duration in the first row.',
        );
        return null;
      }
    } else {
      if ([
        firstTestName,
        firstTestType,
        firstDuration,
      ].any((e) => e.trim().isNotEmpty)) {
        _snackBar.showError(
          'You selected Bulk Upload, but test metadata was found. Please use Test Upload instead.',
        );
        return null;
      }

      for (var i = 1; i < dataRows.length; i++) {
        final rowMap = Map.fromIterables(
          headers,
          dataRows[i].map((e) => e.toString().trim()),
        );
        if ((rowMap['test_name']?.isNotEmpty ?? false) ||
            (rowMap['test_type']?.isNotEmpty ?? false) ||
            (rowMap['duration']?.isNotEmpty ?? false)) {
          _snackBar.showError(
            'Test fields should not appear in any row for bulk upload.',
          );
          return null;
        }
      }
    }

    final grouped = <String, Map<String, dynamic>>{};
    int rowIndex = 1;
    bool hasStartedProcessing = false;

    for (final row in dataRows) {
      rowIndex++;

      final isEmptyRow = row.every(
        (field) => field == null || field.toString().trim().isEmpty,
      );

      if (isEmptyRow && hasStartedProcessing) {
        _log.i('🛑 Stopping at first empty row at index $rowIndex.');
        break; // Stop reading further
      }

      if (isEmptyRow && !hasStartedProcessing) {
        continue; // Skip leading empty rows
      }

      hasStartedProcessing = true;

      final rowMap = Map.fromIterables(
        headers,
        row.map((e) => e.toString().trim()),
      );
      final srNo = rowMap['sr_no'] ?? 'unknown';
      final questionType = rowMap['question_type']?.toLowerCase() ?? '';
      final lang = rowMap['language_code'];

      final requiredHeaders =
          questionType == 'desc' ? descRequiredHeaders : otherRequiredHeaders;
      for (final key in requiredHeaders) {
        final value = rowMap[key]?.toString().trim();
        if (value == null || value.isEmpty) {
          _snackBar.showError(
            'Missing value for "$key" in row $rowIndex (sr_no: $srNo)',
          );
          return null;
        }
      }

      if (isTestUpload &&
          questionType == 'desc' &&
          firstTestType.toLowerCase() != 'desc') {
        _snackBar.showError(
          'Skipped question at row $rowIndex (sr_no: $srNo): DESC type must have test_type = desc',
        );
        continue;
      }

      if (lang == null || lang.isEmpty) {
        _snackBar.showError(
          'Missing language_code in row $rowIndex (sr_no: $srNo)',
        );
        return null;
      }

      // 💥 Prevent duplicate language entry per sr_no
      if (grouped[srNo]?['languages']?[lang] != null) {
        _snackBar.showError(
          'Duplicate language "$lang" for sr_no "$srNo" at row $rowIndex.',
        );
        return null;
      }

      final langData =
          questionType == 'desc'
              ? {"question_txt": rowMap['question_text']}
              : {
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
          "question_type": questionType,
          "difficulty_level": rowMap['difficulty_level'],
          "subject_name": rowMap['subject_name'],
          "topic_name": rowMap['topic_name'],
          "marks": int.tryParse(rowMap['marks'] ?? '1') ?? 1,
          "languages": <String, dynamic>{},
        };
        if (isTestUpload) {
          base['test_name'] = firstTestName;
          base['duration'] = int.tryParse(firstDuration) ?? 1;
          base['test_type'] = firstTestType;
        }
        return base;
      });

      grouped[srNo]!["languages"][lang] = langData;
    }

    if (grouped.isEmpty) {
      _snackBar.showError('No valid data found.');
      return null;
    }

    final payload = grouped.values.toList();

    final rpcFunctionName =
        isTestUpload
            ? SupabaseKeys.insertMcqWithTest
            : SupabaseKeys.insertBulkQuestions;

    final rpcResult = await _supabase.rpc(
      rpcFunctionName,
      params: {'payload': payload},
    );

    final response = rpcResult as Map<String, dynamic>?;
    if (response == null) return null;

    return UploadResult(
      successCount: response['inserted'] ?? response['inserted_questions'] ?? 0,
      failCount: response['failed'] ?? 0,
      duplicateCount: response['skipped_duplicates'] ?? 0,
    );
  } catch (e, stack) {
    _log.e('❌ Upload failed: $e\n$stack');
    if (e.toString().toLowerCase().contains('daily test') == true) {
      _snackBar.showError('A daily test has already been uploaded today.');
    } else {
      _snackBar.showError('Upload failed: ${e.toString()}');
    }
  }
}

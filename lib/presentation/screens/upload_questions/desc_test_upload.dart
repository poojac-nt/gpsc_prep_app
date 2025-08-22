import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/presentation/screens/upload_questions/upload_csv_service.dart';
import 'package:gpsc_prep_app/utils/constants/supabase_keys.dart';

final _log = getIt<LogHelper>();
final _supabase = getIt<SupabaseHelper>().supabase;
final _snackBar = getIt<SnackBarHelper>();

Future<List<Map<String, dynamic>>?> parseDescUploadFile() async {
  try {
    final pickedFileResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
      withData: true,
    );

    if (pickedFileResult == null || pickedFileResult.files.isEmpty) {
      _snackBar.showError('Upload cancelled by user.');
      return null;
    }

    final file = pickedFileResult.files.single;
    final filePath = file.path;
    if (filePath == null) {
      _log.e("❌ File path is null.");
      _snackBar.showError('File path is null.');
      return null;
    }

    late List<List<dynamic>> rows;
    final ext = file.extension?.toLowerCase();

    // --- CSV ---
    if (ext == 'csv') {
      final content = await File(filePath).readAsString();
      rows = const CsvToListConverter().convert(
        content.replaceFirst(RegExp(r'^\ufeff'), ''), // remove BOM
        eol: '\n',
        shouldParseNumbers: false,
      );
    }
    // --- XLSX ---
    else if (ext == 'xlsx') {
      final bytes = await File(filePath).readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet =
          excel.tables.values.isNotEmpty ? excel.tables.values.first : null;
      if (sheet == null || sheet.rows.isEmpty) {
        _log.e("❌ Excel file has no data.");
        _snackBar.showError('Excel file has no data.');
        return null;
      }
      rows =
          sheet.rows
              .map(
                (row) =>
                    row.map((cell) => cell?.value?.toString() ?? '').toList(),
              )
              .toList();
    } else {
      _log.e("❌ Unsupported file format: $ext");
      _snackBar.showError('Unsupported file format');
      return null;
    }

    if (rows.isEmpty) {
      _log.e("❌ The file is empty.");
      _snackBar.showError('The file is empty.');
      return null;
    }

    // --- Headers ---
    final headers =
        rows.first.map((h) => h.toString().trim().toLowerCase()).toList();
    final dataRows = rows.skip(1).toList();

    if (dataRows.isEmpty) {
      _log.e("❌ No data rows found.");
      _snackBar.showError('No data rows found.');
      return null;
    }

    // ✅ Required headers
    const requiredHeaders = {
      'sr_no',
      'question',
      'difficulty_level',
      'answer_txt',
      'topic_name',
      'subject_name',
      'language_code',
      'answer',
      'marks',
      'test_name',
      'pages',
    };

    for (final header in requiredHeaders) {
      if (!headers.contains(header)) {
        _log.e("❌ Missing required header: $header");
        _snackBar.showError('Missing required header: $header');
        return null;
      }
    }

    final grouped = <String, Map<String, dynamic>>{};
    int rowIndex = 1; // start after header

    for (final row in dataRows) {
      rowIndex++;

      // --- Skip empty/invisible rows ---
      final isEmptyRow = row.every((cell) {
        final val = cell?.toString().trim() ?? '';
        return val.isEmpty ||
            val.toLowerCase() == 'null' ||
            val.startsWith('=');
      });
      if (isEmptyRow) {
        _log.i("ℹ️ Skipping empty row $rowIndex");
        continue;
      }

      final rowMap = Map.fromIterables(
        headers,
        row.map((e) => e.toString().trim()),
      );

      final srNo = rowMap['sr_no'] ?? 'unknown';
      final lang = rowMap['language_code'];

      // --- Check required values ---
      for (final key in requiredHeaders) {
        final value = rowMap[key]?.toString().trim();
        if (value == null || value.isEmpty) {
          _log.e(
            "❌ Missing value for \"$key\" in row $rowIndex (sr_no: $srNo)",
          );
          _snackBar.showError(
            'Missing value for "$key" in row $rowIndex (sr_no: $srNo)',
          );
          return null;
        }
      }

      // --- Prevent duplicate language for same sr_no ---
      if (grouped[srNo]?['languages']?[lang] != null) {
        _log.e(
          "❌ Duplicate language \"$lang\" for sr_no \"$srNo\" at row $rowIndex",
        );
        _snackBar.showError(
          'Duplicate language "$lang" for sr_no "$srNo" at row $rowIndex.',
        );
        return null;
      }

      final langData = {
        "question_txt": rowMap['question'],
        "answer_txt": rowMap['answer_txt'],
      };

      grouped.putIfAbsent(srNo, () {
        return {
          "question_type": "desc",
          "difficulty_level": rowMap['difficulty_level'],
          "subject_name": rowMap['subject_name'],
          "topic_name": rowMap['topic_name'],
          "marks": int.tryParse(rowMap['marks'] ?? '1') ?? 1,
          "pages": int.tryParse(rowMap['pages'] ?? '0') ?? 0,
          "test_name": rowMap['test_name'],
          "answer": rowMap['answer'],
          "languages": <String, dynamic>{},
        };
      });

      grouped[srNo]!["languages"][lang] = langData;
    }

    if (grouped.isEmpty) {
      _log.e("❌ No valid data found.");
      _snackBar.showError('No valid data found.');
      return null;
    }

    return grouped.values.toList();
  } catch (e, stack) {
    _log.e('❌ Parsing failed (DESC): $e\n$stack');
    _snackBar.showError('Parsing failed: ${e.toString()}');
    return null;
  }
}

Future<UploadResult?> submitDescTestToSupabase({
  required List<Map<String, dynamic>> payload,
}) async {
  try {
    final rpcResult = await _supabase.rpc(
      SupabaseKeys.insertDescWithTest,
      params: {'payload': payload},
    );

    final response = rpcResult as Map<String, dynamic>?;
    if (response == null) return null;

    return UploadResult(
      successCount: response['inserted_questions'] ?? 0,
      failCount: response['failed'] ?? 0,
      duplicateCount: response['skipped_duplicates'] ?? 0,
    );
  } catch (e, stack) {
    _log.e('❌ Upload failed (DESC): $e\n$stack');
    _snackBar.showError('Upload failed: ${e.toString()}');
    return null;
  }
}

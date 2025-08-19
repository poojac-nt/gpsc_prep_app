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

    // ✅ Required headers for descriptive test
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
        _snackBar.showError('Missing required header: $header');
        return null;
      }
    }

    final grouped = <String, Map<String, dynamic>>{};
    int rowIndex = 1;

    for (final row in dataRows) {
      rowIndex++;

      final rowMap = Map.fromIterables(
        headers,
        row.map((e) => e.toString().trim()),
      );

      final srNo = rowMap['sr_no'] ?? 'unknown';
      final lang = rowMap['language_code'];

      for (final key in requiredHeaders) {
        final value = rowMap[key]?.toString().trim();
        if (value == null || value.isEmpty) {
          _snackBar.showError(
            'Missing value for "$key" in row $rowIndex (sr_no: $srNo)',
          );
          return null;
        }
      }

      if (grouped[srNo]?['languages']?[lang] != null) {
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

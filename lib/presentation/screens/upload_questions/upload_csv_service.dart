import 'dart:io';

import 'package:csv/csv.dart';
import 'package:either_dart/either.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/utils/constants/supabase_keys.dart';

final _log = getIt<LogHelper>();
final _supabase = getIt<SupabaseHelper>().supabase;

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

// ✅ URL Validator
bool _isValidUrl(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  } catch (e) {
    return false;
  }
}

Future<Either<Failure, List<Map<String, dynamic>>>> parseUploadFile({
  required bool isTestUpload,
}) async {
  try {
    final pickedFileResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
      withData: false,
    );

    if (pickedFileResult == null || pickedFileResult.files.isEmpty) {
      return Left(Failure('Upload cancelled by user.'));
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
      return Left(Failure('Unsupported file format'));
    }

    if (rows.isEmpty) {
      return Left(Failure('The file is empty.'));
    }

    final headers =
        rows.first.map((h) => h.toString().trim().toLowerCase()).toList();
    final dataRows = rows.skip(1).toList();
    if (dataRows.isEmpty) {
      return Left(Failure('No data rows found.'));
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
    final firstOmrLink = firstRowMap['omr_link'] ?? ''; // ✅ Extract omr_link

    if (isTestUpload) {
      if (firstTestName.isEmpty ||
          firstTestType.isEmpty ||
          firstDuration.isEmpty) {
        return Left(
          Failure(
            'Test upload requires test_name, test_type, and duration in the first row.',
          ),
        );
      }

      // ✅ Fail fast: Validate omr_link for prelims
      if (firstTestType.toLowerCase() == 'prelims') {
        if (firstOmrLink.isEmpty) {
          return Left(Failure('omr link is required for test_type prelims.'));
        }
        if (!_isValidUrl(firstOmrLink)) {
          return Left(
            Failure(
              'Invalid omr_link URL: "$firstOmrLink". Must be a valid http/https URL.',
            ),
          );
        }
      }
    } else {
      if ([
        firstTestName,
        firstTestType,
        firstDuration,
      ].any((e) => e.trim().isNotEmpty)) {
        return Left(
          Failure(
            'You selected Bulk Upload, but test metadata was found. Please use Test Upload instead.',
          ),
        );
      }

      for (var i = 1; i < dataRows.length; i++) {
        final rowMap = Map.fromIterables(
          headers,
          dataRows[i].map((e) => e.toString().trim()),
        );
        if ((rowMap['test_name']?.isNotEmpty ?? false) ||
            (rowMap['test_type']?.isNotEmpty ?? false) ||
            (rowMap['duration']?.isNotEmpty ?? false)) {
          return Left(
            Failure(
              'Test fields should not appear in any row for bulk upload.',
            ),
          );
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

      if (isEmptyRow && hasStartedProcessing) break;
      if (isEmptyRow && !hasStartedProcessing) continue;

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
          return Left(
            Failure('Missing value for "$key" in row $rowIndex (sr_no: $srNo)'),
          );
        }
      }

      if (isTestUpload &&
          questionType == 'desc' &&
          firstTestType.toLowerCase() != 'desc') {
        return Left(
          Failure(
            'Skipped question at row $rowIndex (sr_no: $srNo): DESC type must have test_type = desc',
          ),
        );
      }

      if (lang == null || lang.isEmpty) {
        return Left(
          Failure('Missing language_code in row $rowIndex (sr_no: $srNo)'),
        );
      }

      if (grouped[srNo]?['languages']?[lang] != null) {
        return Left(
          Failure(
            'Duplicate language "$lang" for sr_no "$srNo" at row $rowIndex.',
          ),
        );
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

          // ✅ Add omr_link only for prelims test_type
          if (firstTestType.toLowerCase() == 'prelims') {
            base['omr_link'] = firstOmrLink;
          }
        }
        return base;
      });

      grouped[srNo]!["languages"][lang] = langData;
    }

    if (grouped.isEmpty) {
      return Left(Failure('No valid data found.'));
    }

    return Right(grouped.values.toList());
  } catch (e, stack) {
    _log.e('❌ Parsing failed: $e\n$stack');
    return Left(Failure('Parsing failed: ${e.toString()}'));
  }
}

Future<Either<Failure, UploadResult>> submitParsedDataToSupabase({
  required List<Map<String, dynamic>> payload,
  required bool isTestUpload,
}) async {
  try {
    final rpcFunctionName =
        isTestUpload
            ? SupabaseKeys.insertMcqWithTest
            : SupabaseKeys.insertBulkQuestions;

    final rpcResult = await _supabase.rpc(
      rpcFunctionName,
      params: {'payload': payload},
    );

    final response = rpcResult as Map<String, dynamic>?;
    if (response == null) {
      return Left(Failure('Upload failed: No response received.'));
    }

    return Right(
      UploadResult(
        successCount:
            response['inserted'] ?? response['inserted_questions'] ?? 0,
        failCount: response['failed'] ?? 0,
        duplicateCount: response['skipped_duplicates'] ?? 0,
      ),
    );
  } catch (e, stack) {
    _log.e('❌ Upload failed: $e\n$stack');
    if (e.toString().toLowerCase().contains('daily test')) {
      return Left(Failure('A daily test has already been uploaded today.'));
    } else {
      return Left(Failure('Upload failed: ${e.toString()}'));
    }
  }
}

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:either_dart/either.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/rpc_helper.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/utils/constants/supabase_keys.dart';
import 'package:gpsc_prep_app/utils/enums/course_test_type.dart';

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

Future<Either<Failure, List<Map<String, dynamic>>>> parseUploadFile({
  required bool isTestUpload,
}) async {
  try {
    final pickedFileResult = await FilePicker.pickFiles(
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
      final sheet = excel.tables.values.isNotEmpty
          ? excel.tables.values.first
          : null;

      if (sheet == null || sheet.rows.isEmpty) {
        return Left(Failure('Excel file has no data.'));
      }

      rows = sheet.rows
          .map(
            (row) => row.map((cell) => cell?.value?.toString() ?? '').toList(),
          )
          .toList();
    } else {
      return Left(Failure('Unsupported file format.'));
    }

    if (rows.isEmpty) {
      return Left(Failure('The file is empty.'));
    }

    final headers = rows.first
        .map((h) => h.toString().trim().toLowerCase())
        .toList();

    final dataRows = rows.skip(1).toList();

    if (dataRows.isEmpty) {
      return Left(Failure('No data rows found.'));
    }

    final grouped = <String, Map<String, dynamic>>{};
    int rowIndex = 1;
    bool hasStartedProcessing = false;

    for (final row in dataRows) {
      rowIndex++;

      final isEmptyRow = row.every(
        (field) => field == null || field.toString().trim().isEmpty,
      );

      // Skip empty rows before data starts
      if (!hasStartedProcessing && isEmptyRow) {
        continue;
      }

      // Stop processing once trailing empty rows begin
      if (hasStartedProcessing && isEmptyRow) {
        break;
      }

      hasStartedProcessing = true;

      final rowMap = Map.fromIterables(
        headers,
        row.map((e) => e.toString().trim()),
      );

      final srNo = rowMap['sr_no'] ?? 'unknown';
      final questionType = rowMap['question_type']?.toLowerCase() ?? '';
      final lang = rowMap['language_code'];

      if (lang == null || lang.isEmpty) {
        return Left(
          Failure('Missing language_code in row $rowIndex (sr_no: $srNo)'),
        );
      }

      final langData = questionType == 'desc'
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
        return {
          "sr_no": int.tryParse(srNo) ?? 0,
          "question_type": questionType,
          "difficulty_level": rowMap['difficulty_level'],
          "subject_name": rowMap['subject_name'],
          "topic_name": rowMap['topic_name'],
          "marks": int.tryParse(rowMap['marks'] ?? '1') ?? 1,
          "languages": <String, dynamic>{},
          if (isTestUpload) ...{
            "test_name": rowMap['test_name'],
            "test_type": rowMap['test_type'],
            "duration": int.tryParse(rowMap['duration'] ?? '1') ?? 1,
            "omr_link": rowMap['omr_link'],
          },
        };
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
  DateTime? availableAt,
  int? courseId,
  int? priceSingle,
  int? priceDual,
  CourseTestType? testType,
  List<String>? allowedLanguages, // null = default to all languages on backend
}) async {
  try {
    if (payload.isEmpty) {
      return Left(Failure('No questions to upload.'));
    }

    // ===== BULK QUESTION UPLOAD =====
    if (!isTestUpload) {
      String? rpcError;
      final rpcResult = await callRpc(
        call: () => _supabase.rpc(
          SupabaseKeys.insertBulkQuestions,
          params: {'payload': payload},
        ),
        onError: (msg) => rpcError = msg,
      );

      final response = rpcResult as Map<String, dynamic>?;

      if (response == null) {
        return Left(Failure(rpcError ?? 'Upload failed: No response.'));
      }
      if (response['success'] == false) {
        _log.e('❌ RPC failed: ${response['error']}');
        return Left(
          Failure(response['error']?.toString() ?? 'RPC returned failure.'),
        );
      }

      return Right(
        UploadResult(
          successCount: response['inserted'] ?? 0,
          failCount: response['failed'] ?? 0,
          duplicateCount: response['skipped_duplicates'] ?? 0,
        ),
      );
    }

    // ===== TEST UPLOAD FLOW =====

    final firstItem = payload.first;

    final testObject = {
      "name": firstItem['test_name'],
      "type": firstItem['test_type'],
      "duration": firstItem['duration'],
      "available_at": availableAt?.toIso8601String(),
      "omr_link": firstItem['omr_link'],
      if (allowedLanguages != null && allowedLanguages.isNotEmpty)
        "allowed_languages": allowedLanguages,
    };

    final questions = payload.map((item) {
      final question = Map<String, dynamic>.from(item);

      question.remove('test_name');
      question.remove('test_type');
      question.remove('duration');
      question.remove('omr_link');

      return question;
    }).toList();

    final structuredPayload = {"test": testObject, "questions": questions};

    String? rpcError;
    final rpcResult = await callRpc(
      call: () => _supabase.rpc(
        SupabaseKeys.insertMcqWithTest,
        params: {
          'p_course_id': courseId,
          'payload': structuredPayload,
          'p_single_price_id': priceSingle,
          'p_double_price_id': priceDual,
          'p_course_type': testType?.name,
        },
      ),
      onError: (msg) => rpcError = msg,
    );

    final response = rpcResult as Map<String, dynamic>?;

    if (response == null) {
      return Left(Failure(rpcError ?? 'Upload failed: No response.'));
    }
    if (response['success'] == false) {
      _log.e('❌ RPC failed: ${response['error']}');
      return Left(
        Failure(response['error']?.toString() ?? 'RPC returned failure.'),
      );
    }
    return Right(
      UploadResult(
        successCount: response['inserted_questions'] ?? 0,
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

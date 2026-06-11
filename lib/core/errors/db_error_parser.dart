import 'dart:convert';

import 'package:postgrest/postgrest.dart';

class ParsedDbError {
  final String userMessage;
  final String devSnippet;

  const ParsedDbError({required this.userMessage, required this.devSnippet});
}

class RowError {
  final int srNo;
  final List<String> errors;

  RowError({required this.srNo, required this.errors});

  factory RowError.fromJson(Map<String, dynamic> json) {
    return RowError(
      srNo: (json['sr_no'] as num).toInt(),
      errors: List<String>.from(json['errors']),
    );
  }
}

class DbErrorParser {
  static ParsedDbError parse(PostgrestException e) {
    final raw = e.message;
    final code = e.code ?? '';

    final devSnippet = '[PostgrestException] code=$code | message=$raw';
    final userMessage = _classify(raw, code);

    return ParsedDbError(userMessage: userMessage, devSnippet: devSnippet);
  }

  static String _classify(String raw, String code) {
    // 1. Structured row-level errors (bulk insert pattern)
    final jsonMatch = RegExp(
      r'Errors:\s*(\[.*\])',
      dotAll: true,
    ).firstMatch(raw);
    if (jsonMatch != null) {
      return _parseRowErrors(jsonMatch.group(1)!);
    }

    // 2. Duplicate key
    if (raw.contains('duplicate key') || raw.contains('unique constraint')) {
      final matches = RegExp(r'"([^"]+)"').allMatches(raw);
      final constraint = matches.isNotEmpty ? matches.last.group(1) ?? '' : '';
      return _duplicateKeyMessage(constraint);
    }

    // 3. Invalid enum value
    if (raw.contains('invalid input value for enum')) {
      final match = RegExp(r'enum (\w+): "([^"]+)"').firstMatch(raw);
      if (match != null) {
        return 'Invalid value "${match.group(2)}" for field '
            '"${match.group(1)}". Check your data.';
      }
      return 'One or more fields contain an invalid value.';
    }

    // 4. Null / missing required field
    if (raw.contains('null value in column')) {
      final match = RegExp(r'column "([^"]+)"').firstMatch(raw);
      final field = match?.group(1) ?? 'a required field';
      return 'Missing value for "$field". This field cannot be empty.';
    }

    // 5. Foreign key violation
    if (raw.contains('foreign key constraint') ||
        raw.contains('violates foreign key')) {
      return 'This record references something that does not exist. '
          'Check linked IDs.';
    }

    // 6. RAISE EXCEPTION plain text — already human-written in DB
    if (code == 'P0001') {
      return _cleanRaiseMessage(raw);
    }

    // 7. Fallback
    return 'Something went wrong. Please try again or contact support.';
  }

  static String _parseRowErrors(String jsonStr) {
    try {
      final List decoded = jsonDecode(jsonStr);
      final Set<String> uniqueErrors = {};

      for (var row in decoded) {
        final errors = row['errors'] as List;
        for (var e in errors) {
          uniqueErrors.add(e.toString());
        }
      }

      final errorList = uniqueErrors.join(', ');
      return 'There is invalid data in your file, Resolve that before trying again.\n'
          'Issue: $errorList';
    } catch (_) {
      return 'Some questions have invalid data. Check your file and try again.';
    }
  }

  static String _duplicateKeyMessage(String constraint) {
    // Add more constraint names here as you encounter them
    const knownConstraints = {
      'tests_name_key': 'A test with this name already exists.',
      'questions_question_hash_key':
          'One or more questions already exist in the database.',
      'courses_tests_course_id_test_id_key':
          'This test is already linked to the course.',
    };
    return knownConstraints[constraint] ??
        'A duplicate entry was found. This record already exists.';
  }

  static String _cleanRaiseMessage(String raw) {
    return raw
        .replaceAll(RegExp(r'ERROR:\s*', caseSensitive: false), '')
        .trim();
  }
}

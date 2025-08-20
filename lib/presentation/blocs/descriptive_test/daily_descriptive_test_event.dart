import 'dart:io';

import 'package:flutter/cupertino.dart';

@immutable
sealed class DailyDescTestEvent {}

/// Initialize descriptive test session
class DailyTestInit extends DailyDescTestEvent {}

/// Fetch all descriptive tests for the user
class FetchAllTests extends DailyDescTestEvent {}

/// Add or update a text answer for a specific question
class AddTextAnswer extends DailyDescTestEvent {
  final int questionId;
  final String text;

  AddTextAnswer({required this.questionId, required this.text});
}

/// Add or update a PDF answer for a specific question
class AddPdfAnswer extends DailyDescTestEvent {
  final int questionId;
  final File file;

  AddPdfAnswer({required this.questionId, required this.file});
}

/// Remove an answer completely for a specific question
class RemoveAnswer extends DailyDescTestEvent {
  final int questionId;

  RemoveAnswer({required this.questionId});
}

/// Submit descriptive test with all answers
/// (Bloc will handle uploading PDFs before final submission)
class SubmitDescTest extends DailyDescTestEvent {
  /// This stays as int → your test model id
  final int testId;

  SubmitDescTest(this.testId);
}

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:gpsc_prep_app/domain/entities/desc_question_model.dart';

@immutable
sealed class DailyDescTestEvent {}

/// Initialize descriptive test session
class DailyTestInit extends DailyDescTestEvent {}

/// Fetch all descriptive tests for the user
class FetchAllTests extends DailyDescTestEvent {
  final int userId;

  FetchAllTests(this.userId);
}

/// Add or update a text answer for a specific question
class AddTextAnswer extends DailyDescTestEvent {
  final int questionId;
  final String text;

  AddTextAnswer({required this.questionId, required this.text});
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

class DownloadDescTestPdf extends DailyDescTestEvent {
  final DescQuestionModel questionId;
  final int index;
  final String testName;

  DownloadDescTestPdf({
    required this.questionId,
    required this.index,
    required this.testName,
  });
}

class AddFilesAnswer extends DailyDescTestEvent {
  final int questionId;
  final List<File> files;

  AddFilesAnswer({required this.questionId, required this.files});
}

class ResetDescTestState extends DailyDescTestEvent {}

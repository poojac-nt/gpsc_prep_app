part of 'daily_descriptive_test_bloc.dart';

@immutable
sealed class DailyDescTestEvent {}

/// Initialize descriptive test session
class DailyTestInit extends DailyDescTestEvent {}

/// Fetch all descriptive tests for the user
class FetchAllTests extends DailyDescTestEvent {
  final int? courseId;

  FetchAllTests({this.courseId});
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

class AddFilesAnswer extends DailyDescTestEvent {
  final int questionId;
  final List<File> files;

  AddFilesAnswer({required this.questionId, required this.files});
}

class SubmitDescriptiveTestSinglePdf extends DailyDescTestEvent {
  final int testId;
  final File file;

  SubmitDescriptiveTestSinglePdf({required this.testId, required this.file});
}

class ResetDescTestState extends DailyDescTestEvent {}

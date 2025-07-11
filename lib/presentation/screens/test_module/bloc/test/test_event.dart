part of 'test_bloc.dart';

@immutable
sealed class TestEvent {}

class SubmitTest extends TestEvent {
  final int testId;
  final int totalQuestions;
  final List<QuestionLanguageData> questions;
  final List<String?> selectedOptions;
  final List<bool> answeredStatus;
  final int timeTaken;

  SubmitTest(
    this.testId,
    this.totalQuestions,
    this.questions,
    this.selectedOptions,
    this.answeredStatus,
    this.timeTaken,
  );
}

class InsertTestResultEvent extends TestEvent {}

class FetchSingleTestResultEvent extends TestEvent {
  final int testId;

  FetchSingleTestResultEvent({required this.testId});
}

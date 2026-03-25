part of 'test_bloc.dart';

sealed class TestState {}

final class TestInitial extends TestState {}

final class TestResultInitial extends TestState {}

class TestSubmissionFailed extends TestState {
  final Failure failure;

  TestSubmissionFailed(this.failure);
}

class TestSubmitted extends TestState {
  final List<QuestionLanguageData> questions;
  final List<String?> selectedOption;
  final List<bool> answeredStatus;
  final TestResultWithTopScoreModel? serverResult;

  TestSubmitted({
    required this.questions,
    required this.selectedOption,
    required this.answeredStatus,
    this.serverResult,
  });
}

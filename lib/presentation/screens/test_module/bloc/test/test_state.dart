part of 'test_bloc.dart';

@immutable
sealed class TestState {}

final class TestInitial extends TestState {}

class TestResultInitial extends TestState {}

class TestResultLoading extends TestState {}

class TestResultSuccess extends TestState {
  final List<TestResultModel> results;

  TestResultSuccess(this.results);
}

class TestResultFailure extends TestState {
  final Failure message;

  TestResultFailure(this.message);
}

class SingleResultLoading extends TestState {}

class SingleResultSuccess extends TestState {
  final TestResultModel result;

  SingleResultSuccess(this.result);
}

class NoTestResultFound extends TestState {}

class SingleResultFailure extends TestState {
  final Failure message;

  SingleResultFailure(this.message);
}

class TestSubmitted extends TestState {
  final int totalQuestions;
  final int attempted;
  final int notAttempted;
  final int correct;
  final int inCorrect;
  final bool isReview;
  final List<QuestionLanguageData> questions;
  final List<String?> selectedOption;
  final List<bool?> isCorrect;
  final List<bool> answeredStatus;

  TestSubmitted({
    required this.totalQuestions,
    required this.attempted,
    required this.notAttempted,
    required this.correct,
    required this.inCorrect,
    required this.questions,
    required this.selectedOption,
    required this.answeredStatus,
    required this.isReview,
    required this.isCorrect,
  });
}

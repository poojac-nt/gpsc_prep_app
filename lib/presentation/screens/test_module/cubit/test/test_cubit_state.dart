import 'package:flutter/cupertino.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../domain/entities/question_language_model.dart';
import '../../../../../domain/entities/result_model.dart';

@immutable
sealed class TestCubitState {}

final class TestCubitInitial extends TestCubitState {}

class TestCubitResultInitial extends TestCubitState {}

class TestCubitResultLoading extends TestCubitState {}

class TestCubitResultSuccess extends TestCubitState {
  final List<TestResultModel> results;

  TestCubitResultSuccess(this.results);
}

class TestCubitResultFailure extends TestCubitState {
  final Failure message;

  TestCubitResultFailure(this.message);
}

class NoTestCubitResultFound extends TestCubitState {}

class TestCubitSubmissionFailed extends TestCubitState {
  final Failure message;
  TestCubitSubmissionFailed(this.message);
}

class TestCubitSubmitted extends TestCubitState {
  final int totalQuestions;
  final int attempted;
  final int notAttempted;
  final int correct;
  final int inCorrect;
  final bool isReview;
  final List<QuestionLanguageData> questions;
  final List<String?> selectedOption;
  final List<bool?> isCorrect;
  final double score;
  final int timeSpent;
  final List<bool> answeredStatus;

  TestCubitSubmitted({
    required this.totalQuestions,
    required this.attempted,
    required this.notAttempted,
    required this.correct,
    required this.inCorrect,
    required this.questions,
    required this.selectedOption,
    required this.answeredStatus,
    required this.isReview,
    required this.timeSpent,
    required this.score,
    required this.isCorrect,
  });
}

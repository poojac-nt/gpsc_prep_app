import 'package:flutter/cupertino.dart';

import '../../../../../domain/entities/question_language_model.dart';

@immutable
sealed class TestEvent {}

class SubmitTest extends TestEvent {
  final int testId;
  final List<QuestionLanguageData> questions;
  final List<String?> selectedOptions;
  final List<bool> answeredStatus;
  final int? totalQuestions;
  final int? correctAnswers;
  final int? inCorrectAnswers;
  final int? attemptedQuestions;
  final int? notAttemptedQuestions;
  final double? score;
  final int? timeTaken;

  SubmitTest(
    this.testId,
    this.questions,
    this.selectedOptions,
    this.answeredStatus,
    this.totalQuestions,
    this.correctAnswers,
    this.inCorrectAnswers,
    this.attemptedQuestions,
    this.notAttemptedQuestions,
    this.score,
    this.timeTaken,
  );
}

class InsertTestResultEvent extends TestEvent {}

class FetchSingleTestResultEvent extends TestEvent {
  final int testId;

  FetchSingleTestResultEvent({required this.testId});
}

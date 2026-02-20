import 'package:flutter/cupertino.dart';
import 'package:gpsc_prep_app/domain/entities/result_with_top_score_model.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../domain/entities/question_language_model.dart';

@immutable
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

import 'package:flutter/cupertino.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../domain/entities/question_language_model.dart';
import '../../../../../domain/entities/result_model.dart';

@immutable
sealed class TestState {}

final class TestInitial extends TestState {}

final class TestResultInitial extends TestState {}

class SingleResultLoading extends TestState {}

class SingleResultSuccess extends TestState {
  final TestResultModel result;

  SingleResultSuccess(this.result);
}

class SingleResultFailure extends TestState {
  final Failure message;

  SingleResultFailure(this.message);
}

class TestSubmissionFailed extends TestState {
  final Failure message;
  TestSubmissionFailed(this.message);
}

class TestSubmitted extends TestState {
  final List<QuestionLanguageData> questions;
  final List<String?> selectedOption;
  final List<bool> answeredStatus;

  TestSubmitted({
    required this.questions,
    required this.selectedOption,
    required this.answeredStatus,
  });
}

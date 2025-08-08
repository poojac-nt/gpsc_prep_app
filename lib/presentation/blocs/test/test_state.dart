import 'package:flutter/cupertino.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';

import '../../../../../core/error/failure.dart';
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
  final Failure failure;

  SingleResultFailure(this.failure);
}

class TestSubmissionFailed extends TestState {
  final Failure failure;

  TestSubmissionFailed(this.failure);
}

class TestSubmitted extends TestState {
  final List<QuestionModel> questions;
  final List<String?> selectedOption;
  final List<bool> answeredStatus;

  TestSubmitted({
    required this.questions,
    required this.selectedOption,
    required this.answeredStatus,
  });
}

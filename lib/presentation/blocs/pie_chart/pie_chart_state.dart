import 'package:flutter/cupertino.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';

import '../../../../../core/error/failure.dart';

@immutable
sealed class PieChartState {}

class PieChartInitial extends PieChartState {}

class TestSubmitted extends PieChartState {
  final List<QuestionModel> questions;
  final List<String?> selectedOption;
  final List<bool> answeredStatus;

  TestSubmitted({
    required this.questions,
    required this.selectedOption,
    required this.answeredStatus,
  });
}

class CorrectnessCountsLoading extends PieChartState {}

class CorrectnessCountsSuccess extends PieChartState {
  final List<Map<String, dynamic>> questionStats;

  CorrectnessCountsSuccess(this.questionStats);
}

class PieChartResultFailure extends PieChartState {
  final Failure failure;

  PieChartResultFailure(this.failure);
}

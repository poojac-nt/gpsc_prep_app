import 'package:flutter/cupertino.dart';
import 'package:gpsc_prep_app/domain/entities/test_attempt_state_model.dart';

import '../../../core/error/failure.dart';
import '../../../domain/entities/result_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';

@immutable
sealed class DailyTestState {}

final class DailyTestInitial extends DailyTestState {}

class DailyTestFetching extends DailyTestState {}

class DailyTestFetched extends DailyTestState {
  final List<TestModel> dailyTestModel;
  final Map<int, TestAttemptState> testResults;

  DailyTestFetched(this.dailyTestModel, this.testResults);
}

class DailyTestFetchFailed extends DailyTestState {
  final Failure failure;

  DailyTestFetchFailed(this.failure);
}

class DailyTestResultFetching extends DailyTestState {}

class DailyTestResultFetchingFailed extends DailyTestState {
  final Failure failure;

  DailyTestResultFetchingFailed(this.failure);
}

class DailyTestResultFetched extends DailyTestState {
  final List<TestResultModel> testResults;

  DailyTestResultFetched(this.testResults);
}

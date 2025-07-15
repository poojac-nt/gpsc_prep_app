import 'package:flutter/cupertino.dart';

import '../../../../core/error/failure.dart';
import '../../../../domain/entities/daily_test_model.dart';
import '../../../../domain/entities/result_model.dart';

@immutable
sealed class DailyTestState {}

final class DailyTestInitial extends DailyTestState {}

class DailyTestFetching extends DailyTestState {}

class DailyTestFetched extends DailyTestState {
  final List<DailyTestModel> dailyTestModel;
  final Map<int, TestResultModel> testResults;
  final Map<int, Set<String>> languages;

  DailyTestFetched(this.dailyTestModel, this.testResults, this.languages);
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

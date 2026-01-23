import 'package:gpsc_prep_app/domain/entities/daily_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';

import '../../../core/error/failure.dart';

sealed class PrelimsTestState {}

class PrelimsTestFetching extends PrelimsTestState {}

class PrelimsTestFetched extends PrelimsTestState {
  final List<DailyTestModel> prelimsTests;
  final Map<int, TestResultModel> testResults;
  PrelimsTestFetched(this.prelimsTests, this.testResults);
}

class PrelimsTestFetchedFailed extends PrelimsTestState {
  final Failure failure;

  PrelimsTestFetchedFailed(this.failure);
}

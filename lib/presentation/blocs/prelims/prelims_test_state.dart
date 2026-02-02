import 'package:gpsc_prep_app/domain/entities/test_attempt_state_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';

import '../../../core/error/failure.dart';

sealed class PrelimsTestState {}

class PrelimsTestFetching extends PrelimsTestState {}

class PrelimsTestFetched extends PrelimsTestState {
  final List<TestModel> prelimsTests;
  final Map<int, TestResultModel> testResults;
  final Map<int, TestAttemptState> testAttemptStates;

  PrelimsTestFetched(
    this.prelimsTests,
    this.testResults,
    this.testAttemptStates,
  );
}

class PrelimsTestFetchedFailed extends PrelimsTestState {
  final Failure failure;

  PrelimsTestFetchedFailed(this.failure);
}

part of 'prelims_test_bloc.dart';

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

part of 'daily_test_bloc.dart';

@immutable
sealed class DailyTestState {}

final class DailyTestInitial extends DailyTestState {}

class DailyTestFetching extends DailyTestState {}

class DailyTestFetched extends DailyTestState {
  final List<TestModel> dailyTestModel;
  final Map<int, TestAttemptState> testResults;
  final bool hasReachedMax;
  final bool isFetchingMore;
  final int offset;

  DailyTestFetched(
    this.dailyTestModel,
    this.testResults, {
    this.hasReachedMax = false,
    this.isFetchingMore = false,
    this.offset = 0,
  });

  DailyTestFetched copyWith({
    List<TestModel>? dailyTestModel,
    Map<int, TestAttemptState>? testResults,
    bool? hasReachedMax,
    bool? isFetchingMore,
    int? offset,
  }) {
    return DailyTestFetched(
      dailyTestModel ?? this.dailyTestModel,
      testResults ?? this.testResults,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      offset: offset ?? this.offset,
    );
  }
}

class DailyTestFetchFailed extends DailyTestState {
  final Failure failure;

  DailyTestFetchFailed(this.failure);
}

class DailyTestResultFetchingFailed extends DailyTestState {
  final Failure failure;

  DailyTestResultFetchingFailed(this.failure);
}

class DailyTestResultFetched extends DailyTestState {
  final List<TestResultModel> testResults;

  DailyTestResultFetched(this.testResults);
}

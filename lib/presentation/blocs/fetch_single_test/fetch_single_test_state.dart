part of 'fetch_single_test_bloc.dart';

@immutable
sealed class FetchSingleTestState {}

final class FetchingSingleTestInitial extends FetchSingleTestState {}

class SingleTestFetching extends FetchSingleTestState {}

class SingleTestFetched extends FetchSingleTestState {
  final TestModel dailyTestModel;
  final Map<int, Set<String>> languages;

  SingleTestFetched(this.dailyTestModel, this.languages);
}

class SingleTestFetchingFailed extends FetchSingleTestState {
  final Failure failure;

  SingleTestFetchingFailed(this.failure);
}

class SingleDescTestFetched extends FetchSingleTestState {
  final DescTestModel descModel;

  SingleDescTestFetched(this.descModel);
}

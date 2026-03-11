part of 'fetch_single_test_bloc.dart';

@immutable
sealed class FetchSingleTestEvent {}

class DailyTestInit extends FetchSingleTestEvent {}

class FetchSingleTestFromId extends FetchSingleTestEvent {
  final int testId;

  FetchSingleTestFromId(this.testId);
}

class FetchSingleDescTestFromId extends FetchSingleTestEvent {
  final int testId;

  FetchSingleDescTestFromId(this.testId);
}

part of 'daily_test_bloc.dart';

@immutable
sealed class DailyTestEvent {}

class DailyTestInit extends DailyTestEvent {}

class FetchTests extends DailyTestEvent {}

class LoadMoreTests extends DailyTestEvent {}

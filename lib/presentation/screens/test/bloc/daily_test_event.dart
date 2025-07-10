part of 'daily_test_bloc.dart';

sealed class DailyTestEvent {}

class DailyTestInit extends DailyTestEvent {}

class FetchDailyTest extends DailyTestEvent {}

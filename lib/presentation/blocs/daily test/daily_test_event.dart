import 'package:flutter/cupertino.dart';

@immutable
sealed class DailyTestEvent {}

class DailyTestInit extends DailyTestEvent {}

class FetchDailyTest extends DailyTestEvent {}

class FetchSingleTestFromId extends DailyTestEvent {
  final int testId;
  FetchSingleTestFromId(this.testId);
}

class FetchResults extends DailyTestEvent {
  final int testId;

  FetchResults(this.testId);
}

class FetchTests extends DailyTestEvent {}

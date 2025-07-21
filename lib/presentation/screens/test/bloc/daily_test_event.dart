import 'package:flutter/cupertino.dart';

@immutable
sealed class DailyTestEvent {}

class DailyTestInit extends DailyTestEvent {}

class FetchDailyTest extends DailyTestEvent {}

class FetchResults extends DailyTestEvent {
  final int testId;

  FetchResults(this.testId);
}

class FetchTests extends DailyTestEvent {}

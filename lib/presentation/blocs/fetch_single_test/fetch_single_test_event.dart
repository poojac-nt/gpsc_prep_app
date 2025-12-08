import 'package:flutter/cupertino.dart';

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

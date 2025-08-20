import 'package:flutter/cupertino.dart';

@immutable
sealed class DailyDescTestEvent {}

class DailyTestInit extends DailyDescTestEvent {}

class FetchAllTests extends DailyDescTestEvent {}

class SubmitDescTest extends DailyDescTestEvent {
  final Map<int, String> answers;
  final int testId;

  SubmitDescTest(this.answers, this.testId);
}

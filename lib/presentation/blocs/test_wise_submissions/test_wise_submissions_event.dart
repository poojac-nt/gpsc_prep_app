import 'package:flutter/foundation.dart';

@immutable
sealed class TestWiseSubmissionsEvent {}

class FetchTestWisePendingSubmissions extends TestWiseSubmissionsEvent {
  final int testId;
  FetchTestWisePendingSubmissions(this.testId);
}

import 'package:flutter/material.dart';

import '../../../core/error/failure.dart';

@immutable
sealed class DashboardBlocState {}

class FetchingAttemptedTests extends DashboardBlocState {}

class AttemptedTestsFetched extends DashboardBlocState {
  final int totalTests;
  final double avgScore;
  AttemptedTestsFetched({this.totalTests = 0, this.avgScore = 0.0});
}

class AttemptedTestsFetchedFailed extends DashboardBlocState {
  final Failure failure;
  AttemptedTestsFetchedFailed(this.failure);
}

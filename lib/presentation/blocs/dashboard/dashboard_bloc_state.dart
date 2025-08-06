import 'package:flutter/material.dart';

import '../../../core/error/failure.dart';

@immutable
sealed class DashboardBlocState {}

class FetchingAttemptedTests extends DashboardBlocState {}

class AttemptedTestsFetched extends DashboardBlocState {
  final int totalTests;
  final double avgScore;
  AttemptedTestsFetched({required this.totalTests, required this.avgScore});
}

class AttemptedTestsFetchedFailed extends DashboardBlocState {
  final Failure failure;
  AttemptedTestsFetchedFailed(this.failure);
}

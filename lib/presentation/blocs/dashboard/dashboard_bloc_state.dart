import 'package:flutter/material.dart';
import 'package:gpsc_prep_app/domain/entities/dashboard_analytics.dart';
import 'package:gpsc_prep_app/domain/entities/leaderboard_model.dart';

import '../../../core/error/failure.dart';

@immutable
sealed class DashboardBlocState {}

class DashBoardInitialState extends DashboardBlocState {}

class FetchingDashboardAnalytics extends DashboardBlocState {}

class DashboardAnalyticsFetched extends DashboardBlocState {
  final DashboardAnalytics dashboardAnalytics;
  final List<LeaderboardModel> leaderboardData;

  DashboardAnalyticsFetched({
    required this.dashboardAnalytics,
    required this.leaderboardData,
  });
}

class DashboardAnalyticsFetchedFailed extends DashboardBlocState {
  final Failure failure;

  DashboardAnalyticsFetchedFailed(this.failure);
}

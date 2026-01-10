import 'package:flutter/material.dart';
import 'package:gpsc_prep_app/domain/entities/dashboard_analytics.dart';

import '../../../core/error/failure.dart';

@immutable
sealed class DashboardBlocState {}

class DashBoardInitialState extends DashboardBlocState {}

class FetchingDashboardAnalytics extends DashboardBlocState {}

class DashboardAnalyticsFetched extends DashboardBlocState {
  final DashboardAnalytics dashboardAnalytics;

  DashboardAnalyticsFetched({required this.dashboardAnalytics});
}

class DashboardAnalyticsFetchedFailed extends DashboardBlocState {
  final Failure failure;

  DashboardAnalyticsFetchedFailed(this.failure);
}

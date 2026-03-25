part of 'dashboard_bloc.dart';

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

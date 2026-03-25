part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardBlocEvent {}

class DashBoardInitial extends DashboardBlocEvent {}

class FetchDashboardAnalytics extends DashboardBlocEvent {}

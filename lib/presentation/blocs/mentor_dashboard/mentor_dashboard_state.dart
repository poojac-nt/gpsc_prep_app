part of 'mentor_dashboard_bloc.dart';

abstract class MentorDashboardState {
  const MentorDashboardState();
}

class MentorDashboardInitial extends MentorDashboardState {}

class MentorDashboardLoading extends MentorDashboardState {}

class MentorDashboardLoaded extends MentorDashboardState {
  final MentorDashboardData data;

  const MentorDashboardLoaded(this.data);
}

class MentorDashboardError extends MentorDashboardState {
  final String message;

  const MentorDashboardError(this.message);
}

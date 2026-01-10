part of 'analytics_bloc.dart';

@immutable
sealed class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final OverAllAnalyticsModel analyticsData;

  AnalyticsLoaded(this.analyticsData);
}

class AnalyticsError extends AnalyticsState {
  final Failure message;

  AnalyticsError(this.message);
}

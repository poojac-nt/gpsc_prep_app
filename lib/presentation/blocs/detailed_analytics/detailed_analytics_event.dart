part of 'detailed_analytics_bloc.dart';

@immutable
sealed class DetailedAnalyticsEvent {}

class LoadDetailedDifficultyEvent extends DetailedAnalyticsEvent {
  final DateTime from;
  final DateTime to;

  LoadDetailedDifficultyEvent({required this.from, required this.to});
}

class LoadDetailedQuestionTypeEvent extends DetailedAnalyticsEvent {
  final DateTime from;
  final DateTime to;

  LoadDetailedQuestionTypeEvent({required this.from, required this.to});
}

class LoadDetailedSubjectEvent extends DetailedAnalyticsEvent {
  final DateTime from;
  final DateTime to;

  LoadDetailedSubjectEvent({required this.from, required this.to});
}

class ResetDetailedAnalyticsEvent extends DetailedAnalyticsEvent {}

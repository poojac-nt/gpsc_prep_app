part of 'analytics_bloc.dart';

@immutable
sealed class AnalyticsEvent {}

class FetchTrendData extends AnalyticsEvent {}

class LoadSubjectMasteryEvent extends AnalyticsEvent {
  final AnalyticsRange range;

  LoadSubjectMasteryEvent(this.range);
}

class LoadDifficultyAnalyticsEvent extends AnalyticsEvent {
  final AnalyticsRange range;

  LoadDifficultyAnalyticsEvent(this.range);
}

class LoadQuestionTypeAnalyticsEvent extends AnalyticsEvent {
  final AnalyticsRange range;

  LoadQuestionTypeAnalyticsEvent(this.range);
}

class ResetAnalyticsEvent extends AnalyticsEvent {}

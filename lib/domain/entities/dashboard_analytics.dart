import 'package:json_annotation/json_annotation.dart';

part 'dashboard_analytics.g.dart';

@JsonSerializable(explicitToJson: true)
class DashboardAnalytics {
  @JsonKey(name: 'average_test_accuracy_percent')
  final double averageTestAccuracyPercent;

  @JsonKey(name: 'tests_attempted')
  final int testsAttempted;

  @JsonKey(name: 'total_tests_available')
  final int totalTestsAvailable;

  @JsonKey(name: 'current_streak')
  final int currentStreak;

  @JsonKey(name: 'active_days_last_7')
  final int activeDaysLast7;

  @JsonKey(name: 'active_days_last_30')
  final int activeDaysLast30;

  @JsonKey(name: 'longest_streak')
  final int longestStreak;

  @JsonKey(name: 'last_test')
  final LastTest? lastTest;

  @JsonKey(name: 'user_accuracy_all')
  final double userAllOverAccuracy;

  DashboardAnalytics({
    required this.averageTestAccuracyPercent,
    required this.testsAttempted,
    required this.totalTestsAvailable,
    required this.currentStreak,
    required this.activeDaysLast7,
    required this.activeDaysLast30,
    required this.longestStreak,
    required this.lastTest,
    required this.userAllOverAccuracy,
  });

  factory DashboardAnalytics.fromJson(Map<String, dynamic> json) =>
      _$DashboardAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardAnalyticsToJson(this);
}

@JsonSerializable()
class LastTest {
  @JsonKey(name: 'test_id')
  final int testId;

  @JsonKey(name: 'test_name')
  final String testName;

  @JsonKey(name: 'score')
  final double score;

  @JsonKey(name: 'gained_score')
  final int gainedScore;

  @JsonKey(name: 'weak_areas')
  final WeakArea? weakAreas;

  LastTest({
    required this.testId,
    required this.testName,
    required this.score,
    required this.gainedScore,
    this.weakAreas,
  });

  factory LastTest.fromJson(Map<String, dynamic> json) =>
      _$LastTestFromJson(json);

  Map<String, dynamic> toJson() => _$LastTestToJson(this);
}

@JsonSerializable()
class WeakArea {
  final String subject;

  @JsonKey(name: 'question_type')
  final String questionType;

  @JsonKey(name: 'difficulty_level')
  final String difficultyLevel;

  WeakArea({
    required this.subject,
    required this.questionType,
    required this.difficultyLevel,
  });

  factory WeakArea.fromJson(Map<String, dynamic> json) =>
      _$WeakAreaFromJson(json);

  Map<String, dynamic> toJson() => _$WeakAreaToJson(this);
}

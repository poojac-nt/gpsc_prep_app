// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardAnalytics _$DashboardAnalyticsFromJson(Map<String, dynamic> json) =>
    DashboardAnalytics(
      averageTestAccuracyPercent:
          (json['average_test_accuracy_percent'] as num).toDouble(),
      testsAttempted: (json['tests_attempted'] as num).toInt(),
      totalTestsAvailable: (json['total_tests_available'] as num).toInt(),
      currentStreak: (json['current_streak'] as num).toInt(),
      activeDaysLast7: (json['active_days_last_7'] as num).toInt(),
      activeDaysLast30: (json['active_days_last_30'] as num).toInt(),
      longestStreak: (json['longest_streak'] as num).toInt(),
      lastTest: json['last_test'] == null
          ? null
          : LastTest.fromJson(json['last_test'] as Map<String, dynamic>),
      userAllOverAccuracy: (json['user_accuracy_all'] as num).toDouble(),
    );

Map<String, dynamic> _$DashboardAnalyticsToJson(DashboardAnalytics instance) =>
    <String, dynamic>{
      'average_test_accuracy_percent': instance.averageTestAccuracyPercent,
      'tests_attempted': instance.testsAttempted,
      'total_tests_available': instance.totalTestsAvailable,
      'current_streak': instance.currentStreak,
      'active_days_last_7': instance.activeDaysLast7,
      'active_days_last_30': instance.activeDaysLast30,
      'longest_streak': instance.longestStreak,
      'last_test': instance.lastTest?.toJson(),
      'user_accuracy_all': instance.userAllOverAccuracy,
    };

LastTest _$LastTestFromJson(Map<String, dynamic> json) => LastTest(
      testId: (json['test_id'] as num).toInt(),
      testName: json['test_name'] as String,
      score: (json['score'] as num).toDouble(),
      gainedScore: (json['gained_score'] as num).toInt(),
      weakAreas: json['weak_areas'] == null
          ? null
          : WeakArea.fromJson(json['weak_areas'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LastTestToJson(LastTest instance) => <String, dynamic>{
      'test_id': instance.testId,
      'test_name': instance.testName,
      'score': instance.score,
      'gained_score': instance.gainedScore,
      'weak_areas': instance.weakAreas,
    };

WeakArea _$WeakAreaFromJson(Map<String, dynamic> json) => WeakArea(
      subject: json['subject'] as String,
      questionType: json['question_type'] as String,
      difficultyLevel: json['difficulty_level'] as String,
    );

Map<String, dynamic> _$WeakAreaToJson(WeakArea instance) => <String, dynamic>{
      'subject': instance.subject,
      'question_type': instance.questionType,
      'difficulty_level': instance.difficultyLevel,
    };

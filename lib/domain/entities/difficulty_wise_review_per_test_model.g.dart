// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'difficulty_wise_review_per_test_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestReviewAnalytics _$TestReviewAnalyticsFromJson(Map<String, dynamic> json) =>
    TestReviewAnalytics(
      analyticsType: json['analyticsType'] as String,
      totalQuestionsInTest: (json['total_questions_in_test'] as num).toInt(),
      attemptedCount: (json['attempted_count'] as num).toInt(),
      correctCount: (json['correct_count'] as num).toInt(),
      incorrectCount: (json['incorrect_count'] as num).toInt(),
    );

Map<String, dynamic> _$TestReviewAnalyticsToJson(
        TestReviewAnalytics instance) =>
    <String, dynamic>{
      'analyticsType': instance.analyticsType,
      'total_questions_in_test': instance.totalQuestionsInTest,
      'attempted_count': instance.attemptedCount,
      'correct_count': instance.correctCount,
      'incorrect_count': instance.incorrectCount,
    };

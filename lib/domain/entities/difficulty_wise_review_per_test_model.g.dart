// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'difficulty_wise_review_per_test_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestReviewByDifficulty _$TestReviewByDifficultyFromJson(
        Map<String, dynamic> json) =>
    TestReviewByDifficulty(
      difficultyLevel: json['difficulty_level'] as String,
      totalQuestionsInTest: (json['total_questions_in_test'] as num).toInt(),
      attemptedCount: (json['attempted_count'] as num).toInt(),
      correctCount: (json['correct_count'] as num).toInt(),
      incorrectCount: (json['incorrect_count'] as num).toInt(),
    );

Map<String, dynamic> _$TestReviewByDifficultyToJson(
        TestReviewByDifficulty instance) =>
    <String, dynamic>{
      'difficulty_level': instance.difficultyLevel,
      'total_questions_in_test': instance.totalQuestionsInTest,
      'attempted_count': instance.attemptedCount,
      'correct_count': instance.correctCount,
      'incorrect_count': instance.incorrectCount,
    };

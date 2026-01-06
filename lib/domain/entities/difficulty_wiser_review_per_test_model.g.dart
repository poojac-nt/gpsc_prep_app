// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'difficulty_wiser_review_per_test_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DifficultWiseReviewPerTestModel _$DifficultWiseReviewPerTestModelFromJson(
        Map<String, dynamic> json) =>
    DifficultWiseReviewPerTestModel(
      difficultyLevel: json['difficulty_level'] as String,
      totalQuestionsInTest: (json['total_questions_in_test'] as num).toInt(),
      attemptedCount: (json['attempted_count'] as num).toInt(),
      correctCount: (json['correct_count'] as num).toInt(),
      incorrectCount: (json['incorrect_count'] as num).toInt(),
    );

Map<String, dynamic> _$DifficultWiseReviewPerTestModelToJson(
        DifficultWiseReviewPerTestModel instance) =>
    <String, dynamic>{
      'difficulty_level': instance.difficultyLevel,
      'total_questions_in_test': instance.totalQuestionsInTest,
      'attempted_count': instance.attemptedCount,
      'correct_count': instance.correctCount,
      'incorrect_count': instance.incorrectCount,
    };

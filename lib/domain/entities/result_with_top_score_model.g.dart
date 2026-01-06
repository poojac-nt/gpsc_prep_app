// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_with_top_score_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestResultWithTopScoreModel _$TestResultWithTopScoreModelFromJson(
        Map<String, dynamic> json) =>
    TestResultWithTopScoreModel(
      userId: (json['user_id'] as num).toInt(),
      testId: (json['test_id'] as num).toInt(),
      totalQuestions: (json['total_questions'] as num).toInt(),
      correctAnswers: (json['correct_answers'] as num).toInt(),
      inCorrectAnswers: (json['incorrect_answers'] as num).toInt(),
      attemptedQuestions: (json['attempted_questions'] as num).toInt(),
      notAttemptedQuestions: (json['not_attempted_questions'] as num).toInt(),
      score: (json['score'] as num).toDouble(),
      timeTaken: (json['time_taken'] as num).toInt(),
      topScore: (json['top_score'] as num).toDouble(),
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$TestResultWithTopScoreModelToJson(
        TestResultWithTopScoreModel instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'test_id': instance.testId,
      'total_questions': instance.totalQuestions,
      'correct_answers': instance.correctAnswers,
      'incorrect_answers': instance.inCorrectAnswers,
      'attempted_questions': instance.attemptedQuestions,
      'not_attempted_questions': instance.notAttemptedQuestions,
      'score': instance.score,
      'time_taken': instance.timeTaken,
      'created_at': instance.createdAt,
      'top_score': instance.topScore,
    };

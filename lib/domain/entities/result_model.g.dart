// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestResultModel _$TestResultModelFromJson(Map<String, dynamic> json) =>
    TestResultModel(
      userId: (json['user_id'] as num).toInt(),
      testId: (json['test_id'] as num).toInt(),
      correctAnswers: (json['correct_answers'] as num).toInt(),
      inCorrectAnswers: (json['incorrect_answers'] as num).toInt(),
      attemptedQuestions: (json['attempted_questions'] as num).toInt(),
      notAttemptedQuestions: (json['not_attempted_questions'] as num).toInt(),
      totalMarks: (json['total_marks'] as num).toDouble(),
      timeTaken: (json['time_taken'] as num).toInt(),
    );

Map<String, dynamic> _$TestResultModelToJson(TestResultModel instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'test_id': instance.testId,
      'correct_answers': instance.correctAnswers,
      'incorrect_answers': instance.inCorrectAnswers,
      'attempted_questions': instance.attemptedQuestions,
      'not_attempted_questions': instance.notAttemptedQuestions,
      'total_marks': instance.totalMarks,
      'time_taken': instance.timeTaken,
    };

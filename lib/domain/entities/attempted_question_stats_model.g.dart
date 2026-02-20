// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attempted_question_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttemptedQuestionStat _$AttemptedQuestionStatFromJson(
        Map<String, dynamic> json) =>
    AttemptedQuestionStat(
      totalUsers: (json['totalUsers'] as num).toInt(),
      questionId: (json['question_id'] as num).toInt(),
      attemptedCount: (json['attempted_count'] as num).toInt(),
      notAttemptedCount: (json['not_attempted_count'] as num).toInt(),
    );

Map<String, dynamic> _$AttemptedQuestionStatToJson(
        AttemptedQuestionStat instance) =>
    <String, dynamic>{
      'question_id': instance.questionId,
      'attempted_count': instance.attemptedCount,
      'not_attempted_count': instance.notAttemptedCount,
    };

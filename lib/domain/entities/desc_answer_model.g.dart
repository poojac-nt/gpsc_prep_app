// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'desc_answer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DescAnswerModel _$DescAnswerModelFromJson(Map<String, dynamic> json) =>
    DescAnswerModel(
      userId: (json['user_id'] as num).toInt(),
      testId: (json['test_id'] as num).toInt(),
      questionId: (json['question_id'] as num).toInt(),
      answer: json['answer'],
    );

Map<String, dynamic> _$DescAnswerModelToJson(DescAnswerModel instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'test_id': instance.testId,
      'question_id': instance.questionId,
      'answer': instance.answer,
    };

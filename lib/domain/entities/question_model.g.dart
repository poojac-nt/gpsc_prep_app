// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
  question: json['question'] as String,
  optA: json['optA'] as String,
  optB: json['optB'] as String,
  optC: json['optC'] as String,
  optD: json['optD'] as String,
  questionType: json['questionType'] as String,
  correctAnswer: json['correctAnswer'] as String,
);

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
  'question': instance.question,
  'optA': instance.optA,
  'optB': instance.optB,
  'optC': instance.optC,
  'optD': instance.optD,
  'questionType': instance.questionType,
  'correctAnswer': instance.correctAnswer,
};

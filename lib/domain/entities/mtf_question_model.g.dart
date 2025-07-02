// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mtf_question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MTFQuestion _$MTFQuestionFromJson(Map<String, dynamic> json) => MTFQuestion(
  question: json['question'] as String,
  optA: json['optA'] as String,
  optB: json['optB'] as String,
  optC: json['optC'] as String,
  optD: json['optD'] as String,
  leftItems:
      (json['leftItems'] as List<dynamic>).map((e) => e as String).toList(),
  rightItems:
      (json['rightItems'] as List<dynamic>).map((e) => e as String).toList(),
  correctAnswer: json['correctAnswer'] as String,
);

Map<String, dynamic> _$MTFQuestionToJson(MTFQuestion instance) =>
    <String, dynamic>{
      'question': instance.question,
      'leftItems': instance.leftItems,
      'rightItems': instance.rightItems,
      'optA': instance.optA,
      'optB': instance.optB,
      'optC': instance.optC,
      'optD': instance.optD,
      'correctAnswer': instance.correctAnswer,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_language_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionLanguageData _$QuestionLanguageDataFromJson(
  Map<String, dynamic> json,
) => QuestionLanguageData(
  optA: json['opt_a'] as String,
  optB: json['opt_b'] as String,
  optC: json['opt_c'] as String,
  optD: json['opt_d'] as String,
  explanation: json['explanation'] as String,
  questionTxt: json['question_txt'] as String,
  correctAnswer: json['correct_answer'] as String,
);

Map<String, dynamic> _$QuestionLanguageDataToJson(
  QuestionLanguageData instance,
) => <String, dynamic>{
  'opt_a': instance.optA,
  'opt_b': instance.optB,
  'opt_c': instance.optC,
  'opt_d': instance.optD,
  'explanation': instance.explanation,
  'question_txt': instance.questionTxt,
  'correct_answer': instance.correctAnswer,
};

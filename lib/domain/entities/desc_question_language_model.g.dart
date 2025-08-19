// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'desc_question_language_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DescQuestionLanguageData _$DescQuestionLanguageDataFromJson(
        Map<String, dynamic> json) =>
    DescQuestionLanguageData(
      questionTxt: json['question_txt'] as String,
      answerTxt: json['answer_txt'] as String,
    );

Map<String, dynamic> _$DescQuestionLanguageDataToJson(
        DescQuestionLanguageData instance) =>
    <String, dynamic>{
      'question_txt': instance.questionTxt,
      'answer_txt': instance.answerTxt,
    };

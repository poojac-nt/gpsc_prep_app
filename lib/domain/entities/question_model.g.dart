// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) =>
    QuestionModel(
      questionType: json['questionType'] as String,
      difficultyLevel: json['difficultyLevel'] as String,
      topicName: json['topicName'] as String,
      languages: (json['languages'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          k,
          QuestionLanguageData.fromJson(e as Map<String, dynamic>),
        ),
      ),
    );

Map<String, dynamic> _$QuestionModelToJson(QuestionModel instance) =>
    <String, dynamic>{
      'questionType': instance.questionType,
      'difficultyLevel': instance.difficultyLevel,
      'topicName': instance.topicName,
      'languages': instance.languages,
    };

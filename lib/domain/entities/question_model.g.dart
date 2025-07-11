// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) =>
    QuestionModel(
      questionType: json['question_type'] as String,
      difficultyLevel: json['difficulty_level'] as String,
      questionEn: QuestionLanguageData.fromJson(
        json['question_en'] as Map<String, dynamic>,
      ),
      questionHi:
          json['question_hi'] == null
              ? null
              : QuestionLanguageData.fromJson(
                json['question_hi'] as Map<String, dynamic>,
              ),
      questionGj:
          json['question_gj'] == null
              ? null
              : QuestionLanguageData.fromJson(
                json['question_gj'] as Map<String, dynamic>,
              ),
      createdAt: json['created_at'] as String,
      marks: (json['marks'] as num).toInt(),
    );

Map<String, dynamic> _$QuestionModelToJson(QuestionModel instance) =>
    <String, dynamic>{
      'question_type': instance.questionType,
      'difficulty_level': instance.difficultyLevel,
      'question_en': instance.questionEn,
      'question_hi': instance.questionHi,
      'question_gj': instance.questionGj,
      'created_at': instance.createdAt,
      'marks': instance.marks,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'desc_question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DescQuestionModel _$DescQuestionModelFromJson(Map<String, dynamic> json) =>
    DescQuestionModel(
      questionType: json['question_type'] as String,
      difficultyLevel: const DifficultyLevelConverter()
          .fromJson(json['difficulty_level'] as String),
      questionEn: DescQuestionLanguageData.fromJson(
          json['question_en'] as Map<String, dynamic>),
      questionHi: json['question_hi'] == null
          ? null
          : DescQuestionLanguageData.fromJson(
              json['question_hi'] as Map<String, dynamic>),
      questionGj: json['question_gj'] == null
          ? null
          : DescQuestionLanguageData.fromJson(
              json['question_gj'] as Map<String, dynamic>),
      createdAt: json['created_at'] as String,
      marks: (json['marks'] as num).toInt(),
      questionHash: json['question_hash'] as String,
      subjectName: json['subject_name'] as String,
      topicName: json['topic_name'] as String,
    );

Map<String, dynamic> _$DescQuestionModelToJson(DescQuestionModel instance) =>
    <String, dynamic>{
      'question_type': instance.questionType,
      'difficulty_level':
          const DifficultyLevelConverter().toJson(instance.difficultyLevel),
      'question_en': instance.questionEn,
      'question_hi': instance.questionHi,
      'question_gj': instance.questionGj,
      'created_at': instance.createdAt,
      'marks': instance.marks,
      'question_hash': instance.questionHash,
      'subject_name': instance.subjectName,
      'topic_name': instance.topicName,
    };

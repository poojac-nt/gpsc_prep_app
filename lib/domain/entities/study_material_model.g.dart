// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_material_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyMaterialModel _$StudyMaterialModelFromJson(Map<String, dynamic> json) =>
    StudyMaterialModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      link: json['link'] as String,
      testId: (json['test_id'] as num?)?.toInt(),
      createdAt: json['created_at'] as String,
      language: json['language'] as String,
    );

Map<String, dynamic> _$StudyMaterialModelToJson(StudyMaterialModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'link': instance.link,
      'test_id': instance.testId,
      'created_at': instance.createdAt,
      'language': instance.language,
    };

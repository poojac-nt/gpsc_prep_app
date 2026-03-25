// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectModel _$SubjectModelFromJson(Map<String, dynamic> json) => SubjectModel(
      subjectId: (json['subject_id'] as num).toInt(),
      subjectName: json['subject_name'] as String,
    );

Map<String, dynamic> _$SubjectModelToJson(SubjectModel instance) =>
    <String, dynamic>{
      'subject_id': instance.subjectId,
      'subject_name': instance.subjectName,
    };

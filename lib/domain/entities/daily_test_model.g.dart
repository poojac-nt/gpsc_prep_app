// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_test_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyTestModel _$DailyTestModelFromJson(Map<String, dynamic> json) =>
    DailyTestModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      duration: (json['duration'] as num).toInt(),
      noQuestions: (json['no_questions'] as num).toInt(),
    );

Map<String, dynamic> _$DailyTestModelToJson(DailyTestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'duration': instance.duration,
      'no_questions': instance.noQuestions,
    };

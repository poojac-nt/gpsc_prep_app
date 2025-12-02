// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'desc_test_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DescTestModel _$DescTestModelFromJson(Map<String, dynamic> json) =>
    DescTestModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      totalMarks: (json['total_marks'] as num).toInt(),
      noQuestions: (json['no_questions'] as num).toInt(),
      createdAt: json['created_at'] as String,
    );

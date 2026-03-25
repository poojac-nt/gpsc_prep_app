// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_tests_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AllTestsModel _$AllTestsModelFromJson(Map<String, dynamic> json) =>
    AllTestsModel(
      mcq: (json['mcq'] as List<dynamic>)
          .map((e) => TestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      prelims: (json['prelims'] as List<dynamic>)
          .map((e) => TestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      descriptive: (json['descriptive'] as List<dynamic>)
          .map((e) => DescTestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      mains: (json['mains'] as List<dynamic>)
          .map((e) => DescTestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AllTestsModelToJson(AllTestsModel instance) =>
    <String, dynamic>{
      'mcq': instance.mcq.map((e) => e.toJson()).toList(),
      'prelims': instance.prelims.map((e) => e.toJson()).toList(),
      'descriptive': instance.descriptive.map((e) => e.toJson()).toList(),
      'mains': instance.mains.map((e) => e.toJson()).toList(),
    };

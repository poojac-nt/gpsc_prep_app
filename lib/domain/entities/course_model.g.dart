// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseModel _$CourseModelFromJson(Map<String, dynamic> json) => CourseModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      testType: $enumDecodeNullable(_$CourseTestTypeEnumMap, json['test_type']),
      singleProduct:
          ProductModel.fromJson(json['single_product'] as Map<String, dynamic>),
      tests: json['tests'] == null
          ? null
          : CourseTestsModel.fromJson(json['tests'] as Map<String, dynamic>),
      dualProduct: json['dual_product'] == null
          ? null
          : ProductModel.fromJson(json['dual_product'] as Map<String, dynamic>),
      isActive: json['is_active'] as bool,
      fullCoursePurchaseCount:
          (json['full_course_purchase_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CourseModelToJson(CourseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'test_type': _$CourseTestTypeEnumMap[instance.testType],
      'single_product': instance.singleProduct,
      'dual_product': instance.dualProduct,
      'is_active': instance.isActive,
      'full_course_purchase_count': instance.fullCoursePurchaseCount,
      'tests': instance.tests,
    };

const _$CourseTestTypeEnumMap = {
  CourseTestType.prelims: 'prelims',
  CourseTestType.mains: 'mains',
};

CourseTestsModel _$CourseTestsModelFromJson(Map<String, dynamic> json) =>
    CourseTestsModel(
      prelims: (json['prelims'] as List<dynamic>?)
          ?.map((e) => TestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      descriptive: (json['descriptive'] as List<dynamic>?)
          ?.map((e) => DescTestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CourseTestsModelToJson(CourseTestsModel instance) =>
    <String, dynamic>{
      'prelims': instance.prelims,
      'descriptive': instance.descriptive,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'option_matrix_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OptionMatrixModel _$OptionMatrixModelFromJson(Map<String, dynamic> json) =>
    OptionMatrixModel(
      questionId: (json['question_id'] as num).toInt(),
      selectedOption: json['selected_option'] as String,
      totalUsers: (json['total_users'] as num).toInt(),
    );

Map<String, dynamic> _$OptionMatrixModelToJson(OptionMatrixModel instance) =>
    <String, dynamic>{
      'question_id': instance.questionId,
      'selected_option': instance.selectedOption,
      'total_users': instance.totalUsers,
    };

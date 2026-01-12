// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trend_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrendModel _$TrendModelFromJson(Map<String, dynamic> json) => TrendModel(
      periodType: $enumDecode(_$PeriodTypeEnumMap, json['period_type']),
      periodLabel: json['period_label'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      correctCount: (json['correct_count'] as num).toInt(),
      attemptedCount: (json['attempted_count'] as num).toInt(),
      accuracy: (json['accuracy'] as num).toDouble(),
    );

Map<String, dynamic> _$TrendModelToJson(TrendModel instance) =>
    <String, dynamic>{
      'period_type': _$PeriodTypeEnumMap[instance.periodType]!,
      'period_label': instance.periodLabel,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'correct_count': instance.correctCount,
      'attempted_count': instance.attemptedCount,
      'accuracy': instance.accuracy,
    };

const _$PeriodTypeEnumMap = {
  PeriodType.monthly: 'monthly',
  PeriodType.weekly: 'weekly',
};

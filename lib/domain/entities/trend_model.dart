import 'package:json_annotation/json_annotation.dart';

part 'trend_model.g.dart';

@JsonSerializable()
class TrendModel {
  @JsonKey(name: "period_type")
  PeriodType periodType;
  @JsonKey(name: "period_label")
  String periodLabel;
  @JsonKey(name: "start_date")
  DateTime startDate;
  @JsonKey(name: "end_date")
  DateTime endDate;
  @JsonKey(name: "correct_count")
  int correctCount;
  @JsonKey(name: "attempted_count")
  int attemptedCount;
  @JsonKey(name: "accuracy")
  double accuracy;

  TrendModel({
    required this.periodType,
    required this.periodLabel,
    required this.startDate,
    required this.endDate,
    required this.correctCount,
    required this.attemptedCount,
    required this.accuracy,
  });

  factory TrendModel.fromJson(Map<String, dynamic> json) =>
      _$TrendModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrendModelToJson(this);
}

enum PeriodType {
  @JsonValue("monthly")
  monthly,
  @JsonValue("weekly")
  weekly;

  String get type {
    switch (this) {
      case PeriodType.weekly:
        return 'Weekly';
      case PeriodType.monthly:
        return 'Monthly';
    }
  }

  @override
  String toString() => type;

  static PeriodType fromString(String type) {
    switch (type) {
      case 'weekly':
        return PeriodType.weekly;
      case 'monthly':
        return PeriodType.monthly;
      default:
        throw ArgumentError('Invalid Period type: $type');
    }
  }
}

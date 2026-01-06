import 'package:json_annotation/json_annotation.dart';

part 'daily_test_model.g.dart';

@JsonSerializable()
class DailyTestModel {
  @JsonKey(name: "id")
  int id;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "duration")
  int duration;
  @JsonKey(name: "no_questions")
  int noQuestions;
  @JsonKey(name: "total_marks")
  int totalMarks;

  DailyTestModel({
    required this.id,
    required this.name,
    required this.duration,
    required this.noQuestions,
    required this.totalMarks,
  });

  factory DailyTestModel.fromJson(Map<String, dynamic> json) =>
      _$DailyTestModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailyTestModelToJson(this);
}

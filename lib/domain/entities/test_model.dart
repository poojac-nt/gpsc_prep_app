import 'package:gpsc_prep_app/utils/enums/test_type_enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'test_model.g.dart';

@JsonSerializable()
class TestModel {
  @JsonKey(name: "id")
  int id;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "duration")
  int duration;
  @JsonKey(name: "no_questions")
  int noQuestions;
  @JsonKey(name: "test_type")
  TestType testType;
  @JsonKey(name: "total_marks")
  int totalMarks;

  TestModel({
    required this.id,
    required this.name,
    required this.duration,
    required this.noQuestions,
    required this.testType,
    required this.totalMarks,
  });

  factory TestModel.fromJson(Map<String, dynamic> json) =>
      _$TestModelFromJson(json);

  Map<String, dynamic> toJson() => _$TestModelToJson(this);
}

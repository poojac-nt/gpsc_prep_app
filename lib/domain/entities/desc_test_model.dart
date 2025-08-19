import 'package:json_annotation/json_annotation.dart';

part 'desc_test_model.g.dart';

@JsonSerializable()
class DescTestModel {
  @JsonKey(name: "id")
  int id;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "no_questions")
  int noQuestions;
  @JsonKey(name: "total_marks")
  int totalMarks;

  DescTestModel({
    required this.id,
    required this.name,
    required this.totalMarks,
    required this.noQuestions,
  });

  factory DescTestModel.fromJson(Map<String, dynamic> json) =>
      _$DescTestModelFromJson(json);
}

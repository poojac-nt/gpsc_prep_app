import 'package:gpsc_prep_app/domain/entities/test_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'course_model.g.dart';

@JsonSerializable()
class CourseModel {
  @JsonKey(name: "course_id")
  int id;
  // @JsonKey(name: "created_at")
  // String createdAt;
  @JsonKey(name: "course_name")
  String name;
  @JsonKey(name: "course_description")
  String description;
  @JsonKey(name: "tests")
  List<TestModel> courseTests;

  CourseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.courseTests,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CourseModelToJson(this);
}

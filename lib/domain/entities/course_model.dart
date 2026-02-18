import 'package:json_annotation/json_annotation.dart';

part 'course_model.g.dart';

@JsonSerializable()
class CourseModel {
  @JsonKey(name: "id")
  int id;
  @JsonKey(name: "created_at")
  String createdAt;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "description")
  String description;

  CourseModel({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.description,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CourseModelToJson(this);
}

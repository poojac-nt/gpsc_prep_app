import 'package:json_annotation/json_annotation.dart';

part 'course_payload.g.dart';

@JsonSerializable()
class CoursePayload {
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "description")
  final String? description;

  CoursePayload({required this.name, this.description});

  factory CoursePayload.fromJson(Map<String, dynamic> json) =>
      _$CoursePayloadFromJson(json);

  Map<String, dynamic> toJson() => _$CoursePayloadToJson(this);
}

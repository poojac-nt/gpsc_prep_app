import 'package:json_annotation/json_annotation.dart';

part 'course_payload.g.dart';

@JsonSerializable()
class CoursePayload {
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "description")
  final String? description;
  @JsonKey(name: "single_assessment_price")
  final int? priceSingle;
  @JsonKey(name: "dual_assessment_price")
  final int? priceDual;
  @JsonKey(name: "test_type")
  final String testType;

  CoursePayload({
    required this.name,
    this.description,
    required this.testType,
    this.priceSingle,
    this.priceDual,
  });

  Map<String, dynamic> toJson() => _$CoursePayloadToJson(this);
}

import 'package:gpsc_prep_app/utils/enums/course_test_type.dart';
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
  final CourseTestType testType;

  CoursePayload({
    required this.name,
    this.description,
    required this.testType,
    this.priceSingle,
    this.priceDual,
  });

  factory CoursePayload.fromJson(Map<String, dynamic> json) =>
      _$CoursePayloadFromJson(json);

  Map<String, dynamic> toJson() => _$CoursePayloadToJson(this);
}

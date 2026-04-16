import 'package:gpsc_prep_app/utils/enums/assement_type_enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'verify_purchase_response.g.dart';

@JsonSerializable()
class VerifyPurchaseResponse {
  @JsonKey(name: "is_valid")
  bool isValid;
  @JsonKey(name: "course_id")
  int courseId;
  @JsonKey(name: "test_ids")
  List<String> testIds;
  @JsonKey(name: "assessment_type")
  AssessmentType assessmentType;
  @JsonKey(name: "is_active")
  bool isActive;

  VerifyPurchaseResponse({
    required this.isValid,
    required this.courseId,
    required this.testIds,
    required this.assessmentType,
    required this.isActive,
  });

  factory VerifyPurchaseResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyPurchaseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyPurchaseResponseToJson(this);
}

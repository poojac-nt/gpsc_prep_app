import 'package:gpsc_prep_app/utils/enums/assement_type_enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_purchase_payload.g.dart';

@JsonSerializable()
class UserPurchasePayload {
  @JsonKey(name: "user_id")
  int userId;
  @JsonKey(name: "course_id")
  int courseId;
  @JsonKey(name: "assessment_type")
  AssessmentType assessmentType;

  UserPurchasePayload({
    required this.userId,

    required this.courseId,
    required this.assessmentType,
  });

  factory UserPurchasePayload.fromJson(Map<String, dynamic> json) =>
      _$UserPurchasePayloadFromJson(json);

  Map<String, dynamic> toJson() => _$UserPurchasePayloadToJson(this);
}

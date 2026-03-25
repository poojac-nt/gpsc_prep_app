import 'package:gpsc_prep_app/utils/enums/assement_type_enum.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_purchase_model.g.dart';

@JsonSerializable()
class UserPurchaseModel {
  @JsonKey(name: "id")
  int id;
  @JsonKey(name: "user_id")
  int userId;
  @JsonKey(name: "course_id")
  int courseId;
  @JsonKey(name: "assessment_type")
  AssessmentType assessmentType;
  @JsonKey(name: "created_at")
  String createdAt;

  UserPurchaseModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.assessmentType,
    required this.createdAt,
  });

  factory UserPurchaseModel.fromJson(Map<String, dynamic> json) =>
      _$UserPurchaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserPurchaseModelToJson(this);
}

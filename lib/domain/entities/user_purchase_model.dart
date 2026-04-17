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
  @JsonKey(name: "test_ids")
  String testIds;
  @JsonKey(name: "assessment_type")
  AssessmentType assessmentType;
  @JsonKey(name: "created_at")
  String createdAt;
  @JsonKey(name: "is_active")
  bool isActive;

  UserPurchaseModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.testIds,
    required this.assessmentType,
    required this.createdAt,
    required this.isActive,
  });

  /// Returns the list of purchased test IDs from the comma-separated string.
  List<int> get purchasedTestIdList {
    if (testIds.isEmpty) return [];
    return testIds
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();
  }

  /// Returns true if this purchase unlocks the given test.
  bool isTestUnlocked(int testId) {
    return purchasedTestIdList.contains(testId);
  }

  factory UserPurchaseModel.fromJson(Map<String, dynamic> json) =>
      _$UserPurchaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserPurchaseModelToJson(this);
}

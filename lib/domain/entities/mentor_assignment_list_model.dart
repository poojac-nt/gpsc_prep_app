import 'package:gpsc_prep_app/domain/entities/subject_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mentor_assignment_list_model.g.dart';

@JsonSerializable()
class MentorAssignmentListModel {
  @JsonKey(name: "test_id")
  int testId;
  @JsonKey(name: "test_name")
  String testName;
  @JsonKey(name: "total_assigned_for_test")
  int totalAssignedForTest;
  @JsonKey(name: "all_completed")
  bool allCompleted;
  @JsonKey(name: "subjects")
  List<SubjectModel> subjects;

  MentorAssignmentListModel({
    required this.testId,
    required this.testName,
    required this.totalAssignedForTest,
    required this.allCompleted,
    required this.subjects,
  });

  factory MentorAssignmentListModel.fromJson(Map<String, dynamic> json) =>
      _$MentorAssignmentListModelFromJson(json);

  Map<String, dynamic> toJson() => _$MentorAssignmentListModelToJson(this);
}

import 'package:json_annotation/json_annotation.dart';

part 'mentor_test_submissions.g.dart';

@JsonSerializable()
class MentorTestSubmissions {
  @JsonKey(name: "submission_id")
  int submissionId;
  @JsonKey(name: "mentor_assignment_id")
  int mentorAssignmentId;
  @JsonKey(name: "student_id")
  int studentId;
  @JsonKey(name: "student_name")
  String studentName;
  @JsonKey(name: "submitted_at")
  String submittedAt;
  @JsonKey(name: "is_checked")
  bool isChecked;

  MentorTestSubmissions({
    required this.submissionId,
    required this.mentorAssignmentId,
    required this.studentId,
    required this.studentName,
    required this.submittedAt,
    required this.isChecked,
  });

  factory MentorTestSubmissions.fromJson(Map<String, dynamic> json) =>
      _$MentorTestSubmissionsFromJson(json);

  Map<String, dynamic> toJson() => _$MentorTestSubmissionsToJson(this);
}

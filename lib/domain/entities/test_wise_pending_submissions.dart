import 'package:json_annotation/json_annotation.dart';

part 'test_wise_pending_submissions.g.dart';

@JsonSerializable()
class TestWisePendingSubmission {
  @JsonKey(name: "submission_id")
  int submissionId;
  @JsonKey(name: "student_id")
  int studentId;
  @JsonKey(name: "student_name")
  String studentName;
  @JsonKey(name: "submitted_at")
  String submittedAt;

  TestWisePendingSubmission({
    required this.submissionId,
    required this.studentId,
    required this.studentName,
    required this.submittedAt,
  });

  factory TestWisePendingSubmission.fromJson(Map<String, dynamic> json) =>
      _$TestWisePendingSubmissionFromJson(json);

  Map<String, dynamic> toJson() => _$TestWisePendingSubmissionToJson(this);
}

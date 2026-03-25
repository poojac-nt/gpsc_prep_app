import 'package:json_annotation/json_annotation.dart';

part 'pending_submission.g.dart';

@JsonSerializable()
class PendingSubmission {
  @JsonKey(name: "test_id")
  int testId;
  @JsonKey(name: "test_name")
  String testName;
  @JsonKey(name: "unassigned_submissions")
  int unassignedSubmissions;

  PendingSubmission({
    required this.testId,
    required this.testName,
    required this.unassignedSubmissions,
  });

  factory PendingSubmission.fromJson(Map<String, dynamic> json) =>
      _$PendingSubmissionFromJson(json);

  Map<String, dynamic> toJson() => _$PendingSubmissionToJson(this);
}

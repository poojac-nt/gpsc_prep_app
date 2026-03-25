import 'package:json_annotation/json_annotation.dart';

part 'mentor_dashbord_data.g.dart';

@JsonSerializable()
class MentorDashboardData {
  @JsonKey(name: "latest_assignments")
  List<LatestAssignment> latestAssignments;
  @JsonKey(name: "total_assigned")
  int totalAssigned;
  @JsonKey(name: "total_completed")
  int totalCompleted;

  MentorDashboardData({
    required this.latestAssignments,
    required this.totalAssigned,
    required this.totalCompleted,
  });

  factory MentorDashboardData.fromJson(Map<String, dynamic> json) =>
      _$MentorDashboardDataFromJson(json);

  Map<String, dynamic> toJson() => _$MentorDashboardDataToJson(this);
}

@JsonSerializable()
class LatestAssignment {
  @JsonKey(name: "test_id")
  int testId;
  @JsonKey(name: "test_name")
  String testName;
  @JsonKey(name: "latest_assigned_at")
  DateTime latestAssignedAt;
  @JsonKey(name: "total_students_submissions")
  int totalStudentsSubmissions;
  @JsonKey(name: "assigned_number_for_this_mentor")
  int assignedNumberForThisMentor;

  LatestAssignment({
    required this.testId,
    required this.testName,
    required this.latestAssignedAt,
    required this.totalStudentsSubmissions,
    required this.assignedNumberForThisMentor,
  });

  factory LatestAssignment.fromJson(Map<String, dynamic> json) =>
      _$LatestAssignmentFromJson(json);

  Map<String, dynamic> toJson() => _$LatestAssignmentToJson(this);
}

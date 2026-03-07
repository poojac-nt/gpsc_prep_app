import 'package:json_annotation/json_annotation.dart';

part 'student_list_with_mentor.g.dart';

@JsonSerializable()
class StudentListWithMentor {
  @JsonKey(name: "submission_id")
  int submissionId;
  @JsonKey(name: "student_id")
  int studentId;
  @JsonKey(name: "student_name")
  String studentName;
  @JsonKey(name: "submitted_at")
  String submittedAt;
  @JsonKey(name: "mentors")
  List<Mentor> mentors;

  StudentListWithMentor({
    required this.submissionId,
    required this.studentId,
    required this.studentName,
    required this.submittedAt,
    required this.mentors,
  });

  factory StudentListWithMentor.fromJson(Map<String, dynamic> json) =>
      _$StudentListWithMentorFromJson(json);

  Map<String, dynamic> toJson() => _$StudentListWithMentorToJson(this);
}

@JsonSerializable()
class Mentor {
  @JsonKey(name: "mentor_id")
  int mentorId;
  @JsonKey(name: "mentor_name")
  String mentorName;
  @JsonKey(name: "subject_ids")
  List<int> subjectIds;

  Mentor({
    required this.mentorId,
    required this.mentorName,
    required this.subjectIds,
  });

  factory Mentor.fromJson(Map<String, dynamic> json) => _$MentorFromJson(json);

  Map<String, dynamic> toJson() => _$MentorToJson(this);
}

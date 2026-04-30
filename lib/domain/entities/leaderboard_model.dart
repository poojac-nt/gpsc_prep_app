import 'package:json_annotation/json_annotation.dart';

part 'leaderboard_model.g.dart';

@JsonSerializable()
class LeaderboardModel {
  @JsonKey(name: 'test_type')
  final String testType;
  @JsonKey(name: 'rank')
  final int rank;
  @JsonKey(name: 'student_name')
  final String studentName;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'test_name')
  final String testName;
  @JsonKey(name: 'total_marks')
  final num totalMarks;

  @JsonKey(name: 'profile_picture')
  final String? profilePicture;

  LeaderboardModel({
    required this.testType,
    required this.rank,
    required this.studentName,
    required this.userId,
    required this.totalMarks,
    required this.testName,
    this.profilePicture,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeaderboardModelToJson(this);
}

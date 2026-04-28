import 'package:json_annotation/json_annotation.dart';

part 'leaderboard_screen_model.g.dart';

@JsonSerializable()
class LeaderboardScreenModel {
  @JsonKey(name: "mains")
  List<Main> mains;
  @JsonKey(name: "prelims")
  List<Main> prelims;

  LeaderboardScreenModel({required this.mains, required this.prelims});

  factory LeaderboardScreenModel.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardScreenModelFromJson(json);

  Map<String, dynamic> toJson() => _$LeaderboardScreenModelToJson(this);
}

@JsonSerializable()
class Main {
  @JsonKey(name: "rank")
  int rank;
  @JsonKey(name: "test_id")
  int testId;
  @JsonKey(name: "user_id")
  int userId;
  @JsonKey(name: "full_name")
  String fullName;
  @JsonKey(name: "test_name")
  String testName;
  @JsonKey(name: "total_marks")
  int? totalMarks;
  @JsonKey(name: "profile_picture")
  String? profilePicture;
  @JsonKey(name: "score")
  double? score;

  Main({
    required this.rank,
    required this.testId,
    required this.userId,
    required this.fullName,
    required this.testName,
    this.totalMarks,
    this.profilePicture,
    this.score,
  });

  factory Main.fromJson(Map<String, dynamic> json) => _$MainFromJson(json);

  Map<String, dynamic> toJson() => _$MainToJson(this);
}

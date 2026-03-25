import 'package:json_annotation/json_annotation.dart';

part 'peer_review_model.g.dart';

@JsonSerializable()
class PeerReviewModel {
  @JsonKey(name: "answer_id")
  int answerId;
  @JsonKey(name: "full_name")
  String fullName;
  @JsonKey(name: "user_id")
  int userId;
  @JsonKey(name: "answer")
  dynamic answer;
  @JsonKey(name: "latest_comment")
  String? latestComment;
  @JsonKey(name: "time_since_submission")
  String timeSinceLatestComment;

  PeerReviewModel({
    required this.answerId,
    required this.fullName,
    required this.userId,
    required this.answer,
    required this.timeSinceLatestComment,
    this.latestComment,
  });

  factory PeerReviewModel.fromJson(Map<String, dynamic> json) =>
      _$PeerReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$PeerReviewModelToJson(this);
}

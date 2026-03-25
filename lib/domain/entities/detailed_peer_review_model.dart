import 'package:gpsc_prep_app/utils/enums/user_role.dart';
import 'package:json_annotation/json_annotation.dart';

part 'detailed_peer_review_model.g.dart';

@JsonSerializable()
class DetailedPeerReviewModel {
  @JsonKey(name: "answer_id")
  int answerId;
  @JsonKey(name: "user_id")
  int userId;
  @JsonKey(name: "full_name")
  String fullName;
  @JsonKey(name: "answer")
  dynamic answer;
  @JsonKey(name: "comments")
  List<Comment> comments;

  DetailedPeerReviewModel({
    required this.answerId,
    required this.userId,
    required this.fullName,
    required this.answer,
    required this.comments,
  });

  factory DetailedPeerReviewModel.fromJson(Map<String, dynamic> json) =>
      _$DetailedPeerReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$DetailedPeerReviewModelToJson(this);
}

@JsonSerializable()
class Comment {
  @JsonKey(name: "comment")
  String comment;
  @JsonKey(name: "comment_id")
  int commentId;
  @JsonKey(name: "created_at")
  DateTime createdAt;
  @JsonKey(name: "reviewer_id")
  int reviewerId;
  @JsonKey(name: "reviewer_name")
  String reviewerName;
  @JsonKey(name: "reviewer_role")
  UserRole reviewerRole;
  @JsonKey(name: "time_since_comment")
  String timeSinceComment;
  @JsonKey(name: "time_since_comment_text")
  String timeSinceCommentText;

  Comment({
    required this.comment,
    required this.commentId,
    required this.createdAt,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerRole,
    required this.timeSinceComment,
    required this.timeSinceCommentText,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

import 'package:json_annotation/json_annotation.dart';

part 'mains_test_review_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MainsTestReviewModel {
  @JsonKey(name: "test_id")
  final int testId;

  @JsonKey(name: "test_name")
  final String testName;

  @JsonKey(name: "test_total_marks")
  final int testTotalMarks;

  @JsonKey(name: "submission_pdf_url")
  final String submissionPdfUrl;

  @JsonKey(name: "mentor_reviews")
  final List<MentorReviewDetail> mentorReviews;

  MainsTestReviewModel({
    required this.testId,
    required this.testName,
    required this.testTotalMarks,
    required this.submissionPdfUrl,
    required this.mentorReviews,
  });

  factory MainsTestReviewModel.fromJson(Map<String, dynamic> json) =>
      _$MainsTestReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$MainsTestReviewModelToJson(this);
}

@JsonSerializable()
class MentorReviewDetail {
  @JsonKey(name: "mentor_id")
  final int mentorId;

  @JsonKey(name: "mentor_name")
  final String mentorName;

  @JsonKey(name: "status")
  final String status;

  @JsonKey(name: "total_marks")
  final int totalMarks;

  @JsonKey(name: "feedback")
  final String? feedback;

  @JsonKey(name: "reviewed_pdf_url")
  final String? reviewedPdfUrl;

  @JsonKey(name: "question_scores")
  List<QuestionScoreModel> questionScores;

  @JsonKey(name: "created_at")
  final String? createdAt;

  MentorReviewDetail({
    required this.mentorId,
    required this.mentorName,
    required this.status,
    required this.totalMarks,
    this.feedback,
    this.reviewedPdfUrl,
    required this.questionScores,
    this.createdAt,
  });

  factory MentorReviewDetail.fromJson(Map<String, dynamic> json) =>
      _$MentorReviewDetailFromJson(json);

  Map<String, dynamic> toJson() => _$MentorReviewDetailToJson(this);
}

@JsonSerializable()
class QuestionScoreModel {
  @JsonKey(name: "question_id")
  final int questionId;

  @JsonKey(name: "gained_marks")
  final int? gainedMarks;

  @JsonKey(name: "total_marks")
  final int totalMarks;

  QuestionScoreModel({
    required this.questionId,
    this.gainedMarks,
    required this.totalMarks,
  });

  factory QuestionScoreModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionScoreModelFromJson(json);
}

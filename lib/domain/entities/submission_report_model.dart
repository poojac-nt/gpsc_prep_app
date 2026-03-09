import 'package:json_annotation/json_annotation.dart';

part 'submission_report_model.g.dart';

@JsonSerializable()
class SubmissionReportModel {
  @JsonKey(name: "submission_pdf_url")
  String? submissionPdfUrl;
  @JsonKey(name: "test_id")
  int testId;
  @JsonKey(name: "questions")
  List<Question> questions;

  SubmissionReportModel({
    this.submissionPdfUrl,
    required this.testId,
    required this.questions,
  });

  factory SubmissionReportModel.fromJson(Map<String, dynamic> json) =>
      _$SubmissionReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubmissionReportModelToJson(this);
}

@JsonSerializable()
class Question {
  @JsonKey(name: "marks")
  int maxMarks;
  @JsonKey(name: "question_id")
  int questionId;
  @JsonKey(name: "question_order")
  int questionOrder;

  Question({
    required this.maxMarks,
    required this.questionId,
    required this.questionOrder,
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}

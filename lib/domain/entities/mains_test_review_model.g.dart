// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mains_test_review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MainsTestReviewModel _$MainsTestReviewModelFromJson(
        Map<String, dynamic> json) =>
    MainsTestReviewModel(
      testId: (json['test_id'] as num).toInt(),
      testName: json['test_name'] as String,
      testTotalMarks: (json['test_total_marks'] as num).toInt(),
      submissionPdfUrl: json['submission_pdf_url'] as String,
      mentorReviews: (json['mentor_reviews'] as List<dynamic>)
          .map((e) => MentorReviewDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MainsTestReviewModelToJson(
        MainsTestReviewModel instance) =>
    <String, dynamic>{
      'test_id': instance.testId,
      'test_name': instance.testName,
      'test_total_marks': instance.testTotalMarks,
      'submission_pdf_url': instance.submissionPdfUrl,
      'mentor_reviews': instance.mentorReviews.map((e) => e.toJson()).toList(),
    };

MentorReviewDetail _$MentorReviewDetailFromJson(Map<String, dynamic> json) =>
    MentorReviewDetail(
      mentorId: (json['mentor_id'] as num).toInt(),
      mentorName: json['mentor_name'] as String,
      status: json['status'] as String,
      totalMarks: (json['total_marks'] as num?)?.toInt(),
      feedback: json['feedback'] as String?,
      reviewedPdfUrl: json['reviewed_pdf_url'] as String?,
      questionScores: (json['question_scores'] as List<dynamic>)
          .map((e) => QuestionScoreModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$MentorReviewDetailToJson(MentorReviewDetail instance) =>
    <String, dynamic>{
      'mentor_id': instance.mentorId,
      'mentor_name': instance.mentorName,
      'status': instance.status,
      'total_marks': instance.totalMarks,
      'feedback': instance.feedback,
      'reviewed_pdf_url': instance.reviewedPdfUrl,
      'question_scores': instance.questionScores,
      'created_at': instance.createdAt,
    };

QuestionScoreModel _$QuestionScoreModelFromJson(Map<String, dynamic> json) =>
    QuestionScoreModel(
      questionId: (json['question_id'] as num).toInt(),
      gainedMarks: (json['gained_marks'] as num?)?.toInt(),
      totalMarks: (json['total_marks'] as num).toInt(),
    );

Map<String, dynamic> _$QuestionScoreModelToJson(QuestionScoreModel instance) =>
    <String, dynamic>{
      'question_id': instance.questionId,
      'gained_marks': instance.gainedMarks,
      'total_marks': instance.totalMarks,
    };

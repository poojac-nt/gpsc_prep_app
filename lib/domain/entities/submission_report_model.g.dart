// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmissionReportModel _$SubmissionReportModelFromJson(
        Map<String, dynamic> json) =>
    SubmissionReportModel(
      submissionPdfUrl: json['submission_pdf_url'] as String?,
      testId: (json['test_id'] as num).toInt(),
      questions: (json['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubmissionReportModelToJson(
        SubmissionReportModel instance) =>
    <String, dynamic>{
      'submission_pdf_url': instance.submissionPdfUrl,
      'test_id': instance.testId,
      'questions': instance.questions,
    };

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
      maxMarks: (json['marks'] as num).toInt(),
      questionId: (json['question_id'] as num).toInt(),
      questionOrder: (json['question_order'] as num).toInt(),
    );

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      'marks': instance.maxMarks,
      'question_id': instance.questionId,
      'question_order': instance.questionOrder,
    };

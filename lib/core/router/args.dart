import 'package:gpsc_prep_app/domain/entities/course_model.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_with_top_score_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';

import '../../domain/entities/desc_test_model.dart';
import '../../domain/entities/detailed_test_result_model.dart';

class TestScreenArgs {
  final bool isFromResult;
  final TestModel testModal;
  final String? language;
  final bool hasPrelimsProgress; // NEW: Indicates if should load saved progress

  TestScreenArgs({
    required this.isFromResult,
    required this.testModal,
    this.language,
    this.hasPrelimsProgress = false,
  });
}

class ResultScreenArgs {
  final bool isFromTest;
  final TestModel testModal;

  ResultScreenArgs({required this.isFromTest, required this.testModal});
}

class TestInstructionScreenArgs {
  final int? testId;
  final TestModel? testModal;

  TestInstructionScreenArgs({this.testId, this.testModal});
}

class ReviewQuestionScreenArgs {
  final bool isTestUpload;
  List<Map<String, dynamic>> payload;
  final bool isFromStudyMaterial;
  final String? title;
  final String? url;
  final String? language;
  final int? courseId; // Updated

  ReviewQuestionScreenArgs({
    required this.isTestUpload,
    required this.payload,
    required this.isFromStudyMaterial,
    this.title,
    this.url,
    this.language,
    this.courseId,
  });
}

class DescReviewQuestionScreenArgs {
  List<Map<String, dynamic>> payload;
  final int? courseId;

  DescReviewQuestionScreenArgs({required this.payload, this.courseId});
}

class DescTestInstructionScreenArgs {
  final DescTestModel? dailyTestModel;
  final int? testId;
  final int? courseId;
  final bool isFromCourse;

  DescTestInstructionScreenArgs({
    this.dailyTestModel,
    this.testId,
    this.courseId,
    this.isFromCourse = false,
  });
}

class DescFullQuestionsScreenArgs {
  final int testId;
  final String testName;
  final int? courseId;

  DescFullQuestionsScreenArgs({
    required this.testId,
    required this.testName,
    this.courseId,
  });
}

class DescTestScreenArgs {
  final DescTestModel dailyTestModel;
  final int initialIndex;

  DescTestScreenArgs({
    required this.dailyTestModel,
    required this.initialIndex,
  });
}

class DescTestResultScreenArgs {
  final String testName;

  DescTestResultScreenArgs({required this.testName});
}

class QuestionPreviewScreenArgs {
  final String testName;
  final List<QuestionModel> questions;
  final TestResultWithTopScoreModel? performanceSummary;
  final TestModel? testModel;
  final List<DetailedTestResult>? detailedResults;

  QuestionPreviewScreenArgs({
    required this.questions,
    required this.testName,
    this.performanceSummary,
    this.testModel,
    this.detailedResults,
  });
}

class PrelimsInstructionScreenArgs {
  final int? testId;
  final TestModel? testModal;
  final bool? hasProgress;

  PrelimsInstructionScreenArgs({this.testId, this.testModal, this.hasProgress});
}

class OMRScreenArgs {
  final TestModel testModal;
  final String? language;

  OMRScreenArgs({required this.testModal, this.language});
}

class CourseDetailsScreenArgs {
  final CourseModel courseModel;

  CourseDetailsScreenArgs({required this.courseModel});
}

class MentorEvaluationScreenArgs {
  // Placeholder fields for future backend integration
  final int? studentId;
  final int mentorAssignmentId;
  final int? testId;
  final int? submissionId;
  final String? studentName;
  final String? testName;
  final bool? isChecked;

  MentorEvaluationScreenArgs({
    this.studentId,
    required this.mentorAssignmentId,
    this.testId,
    this.submissionId,
    this.studentName,
    this.testName,
    this.isChecked,
  });
}

class AssessmentTypeSelectionScreenArgs {
  final CourseModel courseModel;

  AssessmentTypeSelectionScreenArgs({required this.courseModel});
}

class EditMentorScreenArgs {
  final MentorModel mentor;
  EditMentorScreenArgs({required this.mentor});
}

class StudentEvaluationResultScreenArgs {
  final int? testId;
  final String? testName;
  final String? studentName;

  StudentEvaluationResultScreenArgs({
    this.testId,
    this.testName,
    this.studentName,
  });
}

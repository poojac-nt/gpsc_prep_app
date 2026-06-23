import 'package:gpsc_prep_app/domain/entities/course_model.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_model.dart';
import 'package:gpsc_prep_app/domain/entities/product_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_with_top_score_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';
import 'package:gpsc_prep_app/utils/enums/course_test_type.dart';

import '../../domain/entities/desc_question_model.dart';
import '../../domain/entities/desc_test_model.dart';
import '../../domain/entities/detailed_test_result_model.dart';
import '../../domain/entities/mains_test_review_model.dart';

class TestScreenArgs {
  final bool isFromResult;
  final TestModel testModal;
  final String? language;
  final bool hasPrelimsProgress;

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
  final int? courseId;
  final int? priceSingle;
  final int? priceDual;
  final CourseTestType? testType;

  ReviewQuestionScreenArgs({
    required this.isTestUpload,
    required this.payload,
    required this.isFromStudyMaterial,
    this.title,
    this.url,
    this.language,
    this.courseId,
    this.priceSingle,
    this.priceDual,
    this.testType,
  });
}

class DescReviewQuestionScreenArgs {
  List<Map<String, dynamic>> payload;
  final int? courseId;
  final int? priceSingle;
  final int? priceDual;
  final CourseTestType? testType;

  DescReviewQuestionScreenArgs({
    required this.payload,
    this.courseId,
    this.priceSingle,
    this.priceDual,
    this.testType,
  });
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
  final bool isSubmitted;
  final DescTestModel? descTestModel;

  DescFullQuestionsScreenArgs({
    required this.testId,
    required this.testName,
    this.courseId,
    this.isSubmitted = false,
    this.descTestModel,
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

class AdminCourseDetailsScreenArgs {
  final CourseModel courseModel;

  AdminCourseDetailsScreenArgs({required this.courseModel});
}

class MentorEvaluationScreenArgs {
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

  /// If set, uses test-level prices instead of course-level prices.
  final ProductModel? testSingleProduct;
  final ProductModel? testDualProduct;

  AssessmentTypeSelectionScreenArgs({
    required this.courseModel,
    this.testSingleProduct,
    this.testDualProduct,
  });
}

class EditMentorScreenArgs {
  final MentorModel mentor;
  EditMentorScreenArgs({required this.mentor});
}

class StudentEvaluationResultScreenArgs {
  final int? testId;
  final String? testName;
  final String? studentName;
  final int? mentorId;
  final MainsTestReviewModel? reviewModel;
  final int? courseId;
  final DescTestModel? descTestModel;

  StudentEvaluationResultScreenArgs({
    this.testId,
    this.testName,
    this.studentName,
    this.mentorId,
    this.reviewModel,
    this.courseId,
    this.descTestModel,
  });
}

class DescriptiveAnswersScreenArgs {
  final DescTestModel descTestModel;
  final bool isUnlocked;
  final bool showPeerReview;

  DescriptiveAnswersScreenArgs({
    required this.descTestModel,
    this.isUnlocked = false,
    required this.showPeerReview,
  });
}

class DescriptiveAnswerDetailScreenArgs {
  final DescQuestionModel question;
  final int index;
  final int testId;
  final bool isUnlocked;
  final bool showPeerReview;

  DescriptiveAnswerDetailScreenArgs({
    required this.question,
    required this.index,
    required this.testId,
    this.isUnlocked = false,
    this.showPeerReview = false,
  });
}

class PeerReviewAnswerScreenArgs {
  final DescQuestionModel question;
  final int index;
  final String userName;
  final int answerId;

  PeerReviewAnswerScreenArgs({
    required this.question,
    required this.index,
    required this.userName,
    required this.answerId,
  });
}

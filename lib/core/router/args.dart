import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';

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

  ReviewQuestionScreenArgs({
    required this.isTestUpload,
    required this.payload,
    required this.isFromStudyMaterial,
    this.title,
    this.url,
    this.language,
  });
}

class DescReviewQuestionScreenArgs {
  List<Map<String, dynamic>> payload;

  DescReviewQuestionScreenArgs({required this.payload});
}

class DescTestInstructionScreenArgs {
  final DescTestModel dailyTestModel;

  DescTestInstructionScreenArgs({required this.dailyTestModel});
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

  QuestionPreviewScreenArgs({required this.questions, required this.testName});
}

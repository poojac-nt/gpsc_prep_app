import 'package:gpsc_prep_app/domain/entities/daily_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';

class TestScreenArgs {
  final bool isFromResult;
  final DailyTestModel dailyTestModel;
  final String? language;

  TestScreenArgs({
    required this.isFromResult,
    required this.dailyTestModel,
    this.language,
  });
}

class ResultScreenArgs {
  final bool isFromTest;
  final DailyTestModel dailyTestModel;

  ResultScreenArgs({required this.isFromTest, required this.dailyTestModel});
}

class TestInstructionScreenArgs {
  final int? testId;
  final DailyTestModel? dailyTestModel;

  TestInstructionScreenArgs({this.testId, this.dailyTestModel});
}

class ReviewQuestionScreenArgs {
  final bool isTestUpload;

  List<Map<String, dynamic>> payload;

  ReviewQuestionScreenArgs({required this.isTestUpload, required this.payload});
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

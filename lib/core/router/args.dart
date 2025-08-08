import 'package:gpsc_prep_app/domain/entities/daily_test_model.dart';

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
  final Set<String> availableLanguages;

  TestInstructionScreenArgs({
    this.testId,
    this.dailyTestModel,
    required this.availableLanguages,
  });
}

class ReviewQuestionScreenArgs {
  final bool isTestUpload;

  List<Map<String, dynamic>> payload;

  ReviewQuestionScreenArgs({required this.isTestUpload, required this.payload});
}

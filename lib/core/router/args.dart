import 'package:gpsc_prep_app/domain/entities/daily_test_model.dart';

class TestScreenArgs {
  final bool isFromResult;
  final DailyTestModel dailyTestModel;

  TestScreenArgs({required this.isFromResult, required this.dailyTestModel});
}

class ResultScreenArgs {
  final bool isFromTest;
  final DailyTestModel dailyTestModel;

  ResultScreenArgs({required this.isFromTest, required this.dailyTestModel});
}

class TestInstructionScreenArgs {
  final DailyTestModel dailyTestModel;
  final Set<String> availableLanguages;

  TestInstructionScreenArgs({
    required this.dailyTestModel,
    required this.availableLanguages,
  });
}

class ReviewQuestionScreenArgs {
  final bool isTestUpload;

  List<Map<String, dynamic>> payload;

  ReviewQuestionScreenArgs({required this.isTestUpload, required this.payload});
}

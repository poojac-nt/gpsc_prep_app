import 'package:gpsc_prep_app/domain/entities/daily_test_model.dart';

class TestScreenArgs {
  final bool isFromResult;
  final int? testId;
  final String? language;
  final int? testDuration;

  TestScreenArgs({
    required this.isFromResult,
    this.testId,
    this.language,
    this.testDuration,
  });
}

class ResultScreenArgs {
  final bool isFromTest;
  final int? testId;

  ResultScreenArgs({required this.isFromTest, this.testId});
}

class TestInstructionScreenArgs {
  final DailyTestModel dailyTestModel;
  final Set<String> availableLanguages;

  TestInstructionScreenArgs({
    required this.dailyTestModel,
    required this.availableLanguages,
  });
}

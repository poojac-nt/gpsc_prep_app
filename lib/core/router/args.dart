class TestScreenArgs {
  final bool isFromResult;
  final int? testId;
  final String? language;

  TestScreenArgs({required this.isFromResult, this.testId, this.language});
}

class ResultScreenArgs {
  final bool isFromTest;
  final int? testId;

  ResultScreenArgs({required this.isFromTest, this.testId});
}

class TestInstructionScreenArgs {
  final int testId;
  final Set<String> availableLanguages;

  TestInstructionScreenArgs({
    required this.testId,
    required this.availableLanguages,
  });
}

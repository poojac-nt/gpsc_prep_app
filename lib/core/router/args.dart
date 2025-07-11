class TestScreenArgs {
  final bool isFromResult;
  final int? testId;

  TestScreenArgs({required this.isFromResult, this.testId});
}

class ResultScreenArgs {
  final bool isFromTest;
  final int? testId;

  ResultScreenArgs({required this.isFromTest, this.testId});
}

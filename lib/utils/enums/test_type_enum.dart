enum TestType {
  dtmcq,
  mcq,
  prelims;

  String get type {
    switch (this) {
      case TestType.dtmcq:
        return 'Daily Test';
      case TestType.mcq:
        return 'MCQ Test';
      case TestType.prelims:
        return 'Prelims Test';
    }
  }

  @override
  String toString() => type;

  static TestType fromString(String type) {
    switch (type) {
      case 'dtmcq':
        return TestType.dtmcq;
      case 'mcq':
        return TestType.mcq;
      case 'prelims':
        return TestType.prelims;
      default:
        throw ArgumentError('Invalid Test Type: $type');
    }
  }
}

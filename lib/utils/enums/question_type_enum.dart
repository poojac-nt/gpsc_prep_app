enum QuestionType {
  simple,
  mtf,
  fitb,
  stmt,
  desc;

  String get type {
    switch (this) {
      case QuestionType.simple:
        return 'Simple MCQ';
      case QuestionType.mtf:
        return 'Match the following';
      case QuestionType.fitb:
        return 'Fill in the blanks';
      case QuestionType.stmt:
        return 'Statement based';
      case QuestionType.desc:
        return 'Descriptive';
    }
  }

  @override
  String toString() => type;

  static QuestionType fromString(String type) {
    switch (type) {
      case 'desc':
        return QuestionType.desc;
      case 'fitb':
        return QuestionType.fitb;
      case 'mtf':
        return QuestionType.mtf;
      case 'stmt':
        return QuestionType.stmt;
      case 'mod':
        return QuestionType.simple;
      default:
        throw ArgumentError('Invalid difficulty level: $type');
    }
  }
}

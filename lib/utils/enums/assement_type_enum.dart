enum AssessmentType {
  single,
  double;

  String get type {
    switch (this) {
      case AssessmentType.single:
        return 'Single Assessment';
      case AssessmentType.double:
        return 'Double Assessment';
    }
  }

  @override
  String toString() => type;

  static AssessmentType fromString(String type) {
    switch (type) {
      case 'single':
        return AssessmentType.single;
      case 'double':
        return AssessmentType.double;
      default:
        throw ArgumentError('Invalid assessment type: $type');
    }
  }
}

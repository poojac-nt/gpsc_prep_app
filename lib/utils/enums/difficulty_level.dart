enum DifficultyLevel {
  easy,
  mod,
  diff,
  otfb;

  String get level {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.mod:
        return 'Moderate';
      case DifficultyLevel.diff:
        return 'Difficult';
      case DifficultyLevel.otfb:
        return 'Out of the blue';
    }
  }

  @override
  String toString() => level;

  static DifficultyLevel fromString(String level) {
    switch (level) {
      case 'easy':
        return DifficultyLevel.easy;
      case 'mod':
        return DifficultyLevel.mod;
      case 'diff':
        return DifficultyLevel.diff;
      case 'otfb':
        return DifficultyLevel.otfb;
      default:
        throw ArgumentError('Invalid difficulty level: $level');
    }
  }
}

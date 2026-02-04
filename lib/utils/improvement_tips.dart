import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'enums/difficulty_level.dart';
import 'enums/question_type_enum.dart';

class ImprovementTipsProvider {
  static final List<String> _tips = [
    'Your performance in {subject} ({questionType}, {difficulty}) needs attention. Focus on understanding core concepts before attempting speed.',
    'In {subject}, you struggle with {questionType} questions of {difficulty} level. Practice solving them step-by-step.',
    'Weakness detected in {subject} for {questionType} ({difficulty}). Revise theory and solve 10 similar questions daily.',
    '{difficulty} level {questionType} questions in {subject} are reducing your score. Analyze mistakes after every test.',
    'You lose marks in {subject} due to errors in {questionType} ({difficulty}). Focus on elimination techniques.',
    '{subject} needs improvement in {questionType} questions of {difficulty} difficulty. Revisit previous year questions.',
    'Accuracy drops in {subject} for {questionType} type ({difficulty} level). Slow down and recheck assumptions.',
    'Your weak area is {subject} — especially {questionType} questions at {difficulty} level. Strengthen fundamentals.',
    'Frequent mistakes in {subject} ({questionType}, {difficulty}) suggest gaps in conceptual clarity.',
    'Improve your score by practicing more {questionType} questions from {subject} at {difficulty} level.',
    'For {subject}, {questionType} questions of {difficulty} level demand better time management.',
    'Your accuracy in {subject} drops in {difficulty} {questionType} questions. Attempt fewer but correctly.',
    'Focus revision on {subject} topics linked to {questionType} ({difficulty}).',
    '{subject} is a scoring area if you master {questionType} questions at {difficulty} level.',
    'Repeated errors in {subject} ({questionType}, {difficulty}) indicate the need for concept revision.',
    'Strengthen {subject} by practicing mixed {questionType} questions of {difficulty} difficulty.',
    'Your test analysis shows weakness in {subject} — {questionType} ({difficulty}). Allocate daily revision time.',
    'Focus on accuracy first in {subject} before attempting high-volume {questionType} questions ({difficulty}).',
    'Errors in {subject} ({questionType}, {difficulty}) are affecting rank. Review explanations carefully.',
    'Improve confidence in {subject} by mastering {questionType} questions of {difficulty} level.',
    '{difficulty} level {questionType} questions in {subject} should be revised from standard textbooks.',
    'Performance analysis shows {subject} as weak in {questionType} ({difficulty}). Practice targeted sets.',
    'You can boost marks by improving {subject} — especially {questionType} questions at {difficulty} difficulty.',
    'Focus on common traps in {subject} while solving {questionType} questions ({difficulty}).',
    'Consistent practice in {subject} ({questionType}, {difficulty}) will significantly improve your score.',
  ];

  static List<TextSpan> getDeterministicImprovementTip({
    required int? testId,
    required String subject,
    required String questionType,
    required String difficulty,
    required TextStyle normalStyle,
    required TextStyle highlightStyle,
  }) {
    if (_tips.isEmpty) {
      return [TextSpan(text: '', style: normalStyle)];
    }
    debugPrint("$difficulty,$questionType,$subject");

    final seed = ((testId ?? 0) * 100000) + getIt<CacheManager>().getUserId();

    final random = Random(seed);

    final template = _tips[random.nextInt(_tips.length)];

    final List<TextSpan> spans = [];
    final regex = RegExp(r'\{(subject|questionType|difficulty)\}');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(template)) {
      // normal text before placeholder
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: template.substring(lastMatchEnd, match.start),
            style: normalStyle,
          ),
        );
      }

      final placeholder = match.group(1);
      late final String value;

      switch (placeholder) {
        case 'subject':
          value = subject;
          break;
        case 'questionType':
          value =
              QuestionType.values
                  .firstWhere(
                    (e) => e.name == questionType.trim().toLowerCase(),
                  )
                  .type;
          break;
        case 'difficulty':
          value =
              DifficultyLevel.values
                  .firstWhere((e) => e.name == difficulty.trim().toLowerCase())
                  .level;
          break;
      }

      spans.add(TextSpan(text: value, style: highlightStyle));
      lastMatchEnd = match.end;
    }

    // remaining text after last placeholder
    if (lastMatchEnd < template.length) {
      spans.add(
        TextSpan(text: template.substring(lastMatchEnd), style: normalStyle),
      );
    }

    return spans;
  }
}

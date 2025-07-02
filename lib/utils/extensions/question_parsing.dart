import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import '../../domain/entities/question_model.dart';

extension QuestionWidgetFormatter on Question {
  /// Returns a Widget based on question type (statement / mtf / mcq)
  Widget toQuestionWidget() {
    switch (questionType.toLowerCase()) {
      case 'statement':
        return _buildStatementWidget();

      case 'mtf':
        return _buildMtfWidget();

      default:
        return _buildMcqWidget();
    }
  }

  /// Widget for Statement-based Question
  Widget _buildStatementWidget() {
    final text = question;
    final statementPattern = RegExp(
      r'(\d\.\s)(.*?)(?=(\d\.\s|$))',
      dotAll: true,
    );

    final firstStatementIndex = text.indexOf('1.');
    if (firstStatementIndex == -1) {
      return Text(text);
    }

    final intro = text.substring(0, firstStatementIndex).trim();
    final statementMatches =
        statementPattern
            .allMatches(text.substring(firstStatementIndex))
            .toList();

    List<Widget> widgets = [];

    if (intro.isNotEmpty) {
      widgets.add(
        Text(
          intro,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    }
    widgets.add(
      Text(
        "Statements:",
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
      ).padAll(3),
    );
    for (final match in statementMatches) {
      final statementText = '${match.group(1)}${match.group(2)!.trim()}';
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(statementText),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// Widget for MTF-based Question (assumes MTF entries are separated by ; and use -> as mapping)
  Widget _buildMtfWidget() {
    String text = question;

    // Split intro and pairs
    int firstOptionIndex = text.indexOf('a)');
    String intro = '';
    String mtfPart = text;

    if (firstOptionIndex != -1) {
      intro = text.substring(0, firstOptionIndex).trim();
      mtfPart = text.substring(firstOptionIndex).trim();
    }

    // Split by option labels (a), b), c), d) ...)
    final optionPattern = RegExp(r'([a-d]\)\s.*?)(?=([a-d]\)|$))', dotAll: true);
    final optionMatches = optionPattern.allMatches(mtfPart);

    List<Widget> widgets = [];

    // Add Intro line (like: "Match the following")
    if (intro.isNotEmpty) {
      widgets.add(
        Text(
          intro,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
      widgets.add(const SizedBox(height: 8));
    }

    // Add each MTF pair as Row (left → right)
    for (final match in optionMatches) {
      final optionText = match.group(1)?.trim() ?? '';

      // Split by "->"
      if (optionText.contains('->')) {
        final parts = optionText.split('->');
        final leftPart = parts[0].trim(); // Example: "a) Delhi"
        final rightPart = parts[1].trim(); // Example: "India"

        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    leftPart,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(rightPart),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(Text(optionText)); // fallback if missing ->
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// Widget for Simple MCQ
  Widget _buildMcqWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}

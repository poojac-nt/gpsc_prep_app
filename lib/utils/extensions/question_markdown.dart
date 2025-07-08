import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/question_language_model.dart';
import 'package:markdown_widget/markdown_widget.dart';

// extension QuestionWidgetFormatter on QuestionLanguageData {
//   // Widget toQuestionWidget() {
//   //   switch (questionType.toLowerCase()) {
//   //     case 'statement':
//   //       return _buildStatementWidget();
//   //
//   //     case 'mtf':
//   //       return _buildMtfWidget();
//   //
//   //     default:
//   //       return _buildMcqWidget();
//   //   }
//   // }
//   /// Widget for Statement-based Question
//   Widget _buildStatementWidget() {
//     final cleanedQuestion = questionTxt.replaceAll(
//       RegExp(r'^\s+', multiLine: true),
//       '',
//     );
//     return MarkdownWidget(shrinkWrap: true, data: cleanedQuestion);
//   }
//
//   Widget _buildMtfWidget() {
//     final cleanedQuestion = questionTxt.replaceAll(
//       RegExp(r'^\s+', multiLine: true),
//       '',
//     );
//     return MarkdownWidget(
//       shrinkWrap: true,
//       data:
//           cleanedQuestion, // The markdown content stored inside your Question model
//     );
//   }
//
//   /// Widget for Simple MCQ
//   Widget _buildMcqWidget() {
//     return MarkdownWidget(
//       shrinkWrap: true,
//       config: MarkdownConfig(
//         configs: [
//           PConfig(
//             textStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//       data: questionTxt,
//     );
//   }
// }
extension QuestionWidgetFormatter on String {
  /// Converts a question string into a Markdown widget based on its type.
  Widget toQuestionWidget(String questionType) {
    final cleanedQuestion = _cleanWhitespace(this);

    switch (questionType.toLowerCase()) {
      case 'statement':
        return _buildStatementWidget(cleanedQuestion);
      case 'mtf':
        return _buildMtfWidget(cleanedQuestion);
      default:
        return _buildMcqWidget(cleanedQuestion);
    }
  }

  /// Clean leading whitespace from each line
  String _cleanWhitespace(String text) {
    return text.replaceAll(RegExp(r'^\s+', multiLine: true), '');
  }

  /// Statement Question Widget
  Widget _buildStatementWidget(String data) {
    return MarkdownWidget(data: data);
  }

  /// Match the Following (MTF) Widget
  Widget _buildMtfWidget(String data) {
    return MarkdownWidget(data: data);
  }

  /// Simple MCQ Widget
  Widget _buildMcqWidget(String data) {
    return MarkdownWidget(data: data);
  }
}

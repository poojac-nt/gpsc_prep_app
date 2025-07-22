import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:markdown_widget/markdown_widget.dart';

extension QuestionWidgetFormatter on String {
  /// Converts a question string into a Markdown widget based on its type.
  Widget toQuestionWidget() {
    return MarkdownWidget(shrinkWrap: true, data: this);
  }
}

import 'package:flutter/material.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class QuestionIndicator extends StatelessWidget {
  const QuestionIndicator({
    super.key,
    this.fillColor = Colors.black,
    this.borderColor = Colors.black,
    required this.text,
  });

  final String text;
  final Color fillColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: fillColor,
            border: Border.all(color: borderColor, width: 2),
          ),
        ),
        10.wGap,
        Text(text),
      ],
    ).padAll(6);
  }
}

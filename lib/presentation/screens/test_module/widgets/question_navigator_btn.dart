import 'package:flutter/material.dart';

import '../../../../utils/app_constants.dart';

class QuestionNavigatorButton extends StatelessWidget {
  const QuestionNavigatorButton({
    super.key,
    required this.text,
    this.backgroundColor = Colors.white,
    this.fontColor = Colors.black,
    this.borderColor = Colors.black,
    required this.onTap,
  });

  final String text;
  final Color backgroundColor;
  final Color fontColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorders.borderRadius,
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Text(text, style: TextStyle(color: fontColor)),
    );
  }
}

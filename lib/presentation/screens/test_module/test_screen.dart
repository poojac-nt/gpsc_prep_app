import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/screens/home/widgets/custom_progress_bar.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/custom_checkbox.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Daily Test", style: AppTexts.titleTextStyle)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomProgressBar(
              text: "Question 1 of 2",
              value: 0.5,
              percentageText: "1 Answered",
            ),
            20.hGap,
            TestModule(
              title: "Question 1",
              cards: [
                Text(
                  "Which of the following is the highest peak of Gujarat ?",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                  ),
                ),
                20.hGap,
                BorderedContainer(
                  radius: BorderRadius.zero,
                  padding: EdgeInsets.zero,
                  child: CustomCheckbox(
                    value: true,
                    isRounded: true,
                    title: " A. Girnar",
                  ),
                ),
                10.hGap,
                BorderedContainer(
                  radius: BorderRadius.zero,
                  padding: EdgeInsets.zero,
                  borderColor: Colors.grey[400],
                  child: CustomCheckbox(
                    value: false,
                    isRounded: true,
                    title: " B. Pavagadh",
                  ),
                ),
                10.hGap,
                BorderedContainer(
                  radius: BorderRadius.zero,
                  padding: EdgeInsets.zero,
                  borderColor: Colors.grey[400],
                  child: CustomCheckbox(
                    value: false,
                    isRounded: true,
                    title: " C. Saputara",
                  ),
                ),
                10.hGap,
                BorderedContainer(
                  radius: BorderRadius.zero,
                  padding: EdgeInsets.zero,
                  borderColor: Colors.grey[400],
                  child: CustomCheckbox(
                    value: false,
                    isRounded: true,
                    title: " D. Vadodara",
                  ),
                ),
                20.hGap,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ActionButton(
                        text: "Previous",
                        onTap: () {},
                        backColor: Colors.white,
                        fontColor: Colors.black,
                      ),
                    ),
                    20.wGap,
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(left: 65.w),
                        child: ActionButton(text: "Submit Text", onTap: () {}),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            20.hGap,
            TestModule(
              title: "Question Navigator",
              cards: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QuestionNavigatorButton(
                      text: "1",
                      onTap: () {},
                      backgroundColor: Colors.black,
                      fontColor: Colors.white,
                    ),
                    10.wGap,
                    QuestionNavigatorButton(text: "2", onTap: () {}),
                    10.wGap,
                  ],
                ),
                10.hGap,
                CustomCheckbox(value: false, title: "Current"),
                CustomCheckbox(value: true, title: "Answered"),
                CustomCheckbox(value: false, title: "Not Answered"),
              ],
            ),
          ],
        ).padAll(AppPaddings.defaultPadding),
      ),
    );
  }
}

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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorders.borderRadius,
          side: BorderSide(color: Colors.black, width: 1),
        ),
      ),
      child: Text(text, style: TextStyle(color: Colors.black)),
    );
  }
}

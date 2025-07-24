import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import '../../widgets/action_button.dart';
import '../dashboard/widgets/custom_progress_bar.dart';
import '../test_module/widgets/question_indicator.dart';
import '../test_module/widgets/question_navigator_btn.dart';

class DescriptiveTestScreen extends StatefulWidget {
  const DescriptiveTestScreen({super.key});

  @override
  State<DescriptiveTestScreen> createState() => _DescriptiveTestScreenState();
}

class _DescriptiveTestScreenState extends State<DescriptiveTestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Descriptive Test', style: AppTexts.titleTextStyle),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.black),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 18.sp),
                5.wGap,
                SizedBox(width: 43.w, child: Text(" 0:10")),
              ],
            ),
          ).padSymmetric(horizontal: 10.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomProgressBar(
              titleText: "Question 1 of 2",
              value: 0.5,
              labelText: "0 Answered",
            ),
            20.hGap,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 25.w),
                      child: ActionButton(text: "Quit Test", onTap: () {}),
                    ),
                  ),
                  100.wGap,
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: ActionButton(
                        text: "Submit Test",
                        onTap: () {
                          context.pop();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            20.hGap,
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: AppBorders.borderRadius,
              ),
              child: Text(
                "Explain the concept of sustainable development and its importance in modern economic planning.Discuss at least three key principles.",
                style: AppTexts.labelTextStyle,
              ),
            ),
            20.hGap,
            Text("Your Answer ", style: AppTexts.labelTextStyle),
            20.hGap,
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: AppBorders.borderRadius,
              ),
              child: TextField(
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: "Type your answer here...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(10.w),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppBorders.borderRadius,
                    borderSide: BorderSide(width: 2, color: Colors.blueAccent),
                  ),
                ),
              ),
            ),
            20.hGap,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: ActionButton(
                    backgroundColor: AppColors.primary,
                    text: "Previous",
                    onTap: () {},
                    fontColor: Colors.white,
                  ),
                ),
                20.wGap,
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.only(left: 65.w),
                    child: ActionButton(
                      text: "Next",
                      backgroundColor: AppColors.primary,
                      onTap: () {},
                    ),
                  ),
                ),
              ],
            ),
            20.hGap,
            TestModule(
              title: "Question Navigator",
              cards: [
                SizedBox(
                  height: 30.h,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder:
                        (context, index) => Padding(
                          padding: EdgeInsets.only(right: 5.w),
                          child: QuestionNavigatorButton(
                            text: "${index + 1}",
                            backgroundColor: Colors.grey,
                            fontColor: Colors.black,

                            borderColor: Colors.grey,

                            onTap: () {},
                          ),
                        ),
                  ),
                ),
                10.hGap,
                QuestionIndicator(
                  text: "Attempted",
                  borderColor: Colors.black,
                  fillColor: Colors.black,
                ),
                QuestionIndicator(
                  text: "Not Attempted",
                  fillColor: Colors.white,
                ),
              ],
            ),
          ],
        ).padAll(AppPaddings.defaultPadding),
      ),
    );
  }
}

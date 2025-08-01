import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/presentation/blocs/timer/timer_event.dart';
import 'package:gpsc_prep_app/presentation/widgets/custom_alertdialog.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../blocs/timer/timer_bloc.dart';
import '../../widgets/action_button.dart';
import '../../widgets/bordered_container.dart';
import '../dashboard/widgets/custom_progress_bar.dart';
import '../test_module/cubit/question/question_cubit_state.dart';
import '../test_module/widgets/question_indicator.dart';
import '../test_module/widgets/question_navigator_btn.dart';

class DescriptiveTestScreen extends StatefulWidget {
  const DescriptiveTestScreen({super.key});

  @override
  State<DescriptiveTestScreen> createState() => _DescriptiveTestScreenState();
}

class _DescriptiveTestScreenState extends State<DescriptiveTestScreen> {
  ScrollController _scrollController = ScrollController();
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
        controller: _scrollController,
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
                    child: ActionButton(
                      text: "Quit Test",
                      onTap: () {
                        context.go(AppRoutes.studentDashboard);
                      },
                    ),
                  ),
                  100.wGap,
                  Expanded(
                    child: ActionButton(
                      text: "Submit Test",
                      onTap: () {
                        context.pushReplacement(
                          AppRoutes.descriptiveTestResultScreen,
                        );
                      },
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Question 1",
                    style: AppTexts.labelTextStyle.copyWith(fontSize: 20.sp),
                  ),
                  15.hGap,
                  Text(
                    "Explain the concept of sustainable development and its importance in modern economic planning.Discuss at least three key principles.",
                    style: AppTexts.labelTextStyle,
                  ),
                ],
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
                  child: ActionButton(
                    backgroundColor: AppColors.primary,
                    text: "Previous",
                    onTap: () {
                      _scrollController.animateTo(
                        0.0,
                        duration: Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                      );
                    },
                    fontColor: Colors.white,
                  ),
                ),
                150.wGap,
                Expanded(
                  child: ActionButton(
                    text: "Next",
                    backgroundColor: AppColors.primary,
                    onTap: () {
                      _scrollController.animateTo(
                        0.0,
                        duration: Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                      );
                    },
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

  // void _buildAutoSubmitDialog(BuildContext context, TestCubitSubmitted state) {
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       final total = state.totalQuestions;
  //       final attempted = state.answeredStatus.where((status) => status).length;
  //       return CustomAlertdialog(
  //         title: "Time is over",
  //         mainContent: "You have attempted $attempted out of $total questions.",
  //         content:
  //             'Your time for this test has ended. Submitting your answers now and showing your results.',
  //         actions: [
  //           ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: AppColors.primary,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //             ),
  //             child: Text(
  //               "View Result",
  //               style: AppTexts.title.copyWith(color: Colors.white),
  //             ),
  //             onPressed: () {
  //               context.pop(); // close dialog
  //               context.pushReplacement(
  //                 AppRoutes.resultScreen,
  //                 extra: ResultScreenArgs(
  //                   isFromTest: true,
  //                   testId: widget.testId,
  //                   testName: widget.testName,
  //                 ),
  //               );
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _buildSubmitDialog(
    BuildContext context,
    QuestionCubitLoaded state,
    int timeTaken,
    List<int> marks,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final total = state.questions.length;
        final attempted = state.answeredStatus.where((status) => status).length;
        return CustomAlertdialog(
          title: "Submit Test",
          mainContent: "You have attempted $attempted out of $total questions.",
          content: "Are you sure you want to submit the test?",
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Submit",
                style: AppTexts.title.copyWith(color: Colors.white),
              ),
              onPressed: () {
                context.pop(); // close dialog
                context.read<TimerBloc>().add(TimerStop());
              },
            ),
          ],
        );
      },
    );
  }

  Padding _buildWhenLoading() {
    return Padding(
      padding: EdgeInsets.all(AppPaddings.defaultPadding),
      child: Skeletonizer(
        enabled: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fake progress bar
            CustomProgressBar(
              titleText: "Question 1 of 10",
              value: 0.1,
              labelText: "0 Answered",
            ),
            20.hGap,
            // Question Title
            TestModule(
              title: "Question 1",
              cards: [
                // Fake question
                Text("This is a sample question text."),
                10.hGap,
                // Fake options
                Column(
                  children: List.generate(4, (index) {
                    return BorderedContainer(
                      padding: EdgeInsets.zero,
                      radius: BorderRadius.circular(10),
                      borderColor: AppColors.accentColor,
                      child: RadioListTile<String>(
                        value: 'Option $index',
                        groupValue: null,
                        onChanged: null,
                        title: Text("Option $index"),
                      ),
                    ).padAll(5);
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

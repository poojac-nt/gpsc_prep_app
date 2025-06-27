import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/screens/home/widgets/custom_progress_bar.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test_event.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/custom_checkbox.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import 'bloc/test_bloc.dart';
import 'bloc/test_state.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Daily Test", style: AppTexts.titleTextStyle)),
      body: BlocBuilder<QuestionBloc, QuestionState>(
        builder: (context, state) {
          if (state is QuestionInitial) {
            return Center(child: Text("Loading..."));
          } else if (state is QuestionLoaded) {
            var question = state.questions[state.currentIndex];
            print(question);
            var progress = state.currentIndex / (state.questions.length - 1);
            print(progress);
            return SingleChildScrollView(
              child: Column(
                children: [
                  CustomProgressBar(
                    text:
                        "Question ${state.currentIndex + 1} of ${state.questions.length}",
                    value: progress,
                    percentageText: "1 Answered",
                  ),
                  20.hGap,
                  TestModule(
                    title: "Question ${state.currentIndex + 1}",
                    cards: [
                      Text(
                        question['question'],
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
                          title: question['option 1'],
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
                          title: question['option 2'],
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
                          title: question['option 3'],
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
                          title: question['option 4'],
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
                              onTap: () {
                                state.currentIndex > 0
                                    ? context.read<QuestionBloc>().add(
                                      PrevQuestion(),
                                    )
                                    : null;
                              },
                              backColor: Colors.white,
                              fontColor: Colors.black,
                            ),
                          ),
                          20.wGap,
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.only(left: 65.w),
                              child: ActionButton(
                                text: "Next",
                                onTap: () {
                                  state.currentIndex < state.questions.length
                                      ? context.read<QuestionBloc>().add(
                                        NextQuestion(),
                                      )
                                      : null;
                                },
                              ),
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
                      SizedBox(
                        height: 30.h,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: state.questions.length,
                          itemBuilder:
                              (context, index) => Padding(
                                padding: EdgeInsets.only(right: 5.w),
                                child: QuestionNavigatorButton(
                                  text: "${index + 1}",
                                  onTap:
                                      () => context.read<QuestionBloc>().add(
                                        JumpToQuestion(index),
                                      ),
                                ),
                              ),
                        ),
                      ),
                      10.hGap,
                      CustomCheckbox(value: false, title: "Current"),
                      CustomCheckbox(value: true, title: "Answered"),
                      CustomCheckbox(value: false, title: "Not Answered"),
                    ],
                  ),
                ],
              ).padAll(AppPaddings.defaultPadding),
            );
          }
          return Container();
        },
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

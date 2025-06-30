import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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

class TestScreen extends StatefulWidget {
  TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List<String> indicator = ["Current", "Answered", "Not Answered"];
  List<String> optionsKey = ["option 1", "option 2", "option 3", "option 4"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daily Test", style: AppTexts.titleTextStyle),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.black),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.timer_outlined, size: 18.sp),
                5.wGap,
                BlocBuilder<QuestionBloc, QuestionState>(
                  builder: (context, state) {
                    if (State is QuestionInitial) return SizedBox.shrink();
                    if (state is QuestionLoaded) {
                      int minutes = state.tickCount ~/ 60;
                      int seconds = state.tickCount % 60;
                      return Text(
                        "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
                      );
                    }
                    return Container();
                  },
                ),
              ],
            ),
          ).padSymmetric(horizontal: 10.w),
        ],
      ),
      body: BlocBuilder<QuestionBloc, QuestionState>(
        builder: (context, state) {
          if (state is QuestionInitial) {
            return Center(child: Text("Loading..."));
          } else if (state is QuestionLoaded) {
            int? selectedAnswer = state.selectedOption[state.currentIndex];
            var question = state.questions[state.currentIndex];
            var progress = state.currentIndex / (state.questions.length - 1);
            var answered =
                state.answeredStatus.where((value) => value).toList().length;
            print(progress);
            return SingleChildScrollView(
              child: Column(
                children: [
                  CustomProgressBar(
                    text:
                        "Question ${state.currentIndex + 1} of ${state.questions.length}",
                    value: progress,
                    percentageText: "$answered Answered",
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
                      ListView.builder(
                        itemCount: optionsKey.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder:
                            (context, index) => BorderedContainer(
                              padding: EdgeInsets.zero,
                              radius: BorderRadius.zero,
                              child: RadioListTile(
                                value: index,
                                activeColor: Colors.black,
                                groupValue: selectedAnswer,
                                onChanged: (value) {
                                  context.read<QuestionBloc>().add(
                                    AnswerQuestion(value!),
                                  );
                                },
                                title: Text(question[optionsKey[index]]),
                              ),
                            ).padAll(5),
                      ),
                      10.hGap,
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
                              fontColor:
                                  state.currentIndex == 0
                                      ? Colors.grey
                                      : Colors.black,
                            ),
                          ),
                          20.wGap,
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.only(left: 65.w),
                              child: ActionButton(
                                text:
                                    state.currentIndex ==
                                            state.questions.length - 1
                                        ? "Submit Test"
                                        : "Next",
                                onTap: () {
                                  if (state.currentIndex <
                                      state.questions.length - 1) {
                                    context.read<QuestionBloc>().add(
                                      NextQuestion(),
                                    );
                                  } else {
                                    context.read<QuestionBloc>().add(
                                      SubmitTest(),
                                    );
                                    context.push(AppRoutes.resultScreen);
                                  }
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
                                  backgroundColor:
                                      state.currentIndex == index
                                          ? Colors.black
                                          : Colors.white,
                                  fontColor:
                                      state.currentIndex == index
                                          ? Colors.white
                                          : state.answeredStatus[index]
                                          ? Colors.green
                                          : Colors.black,
                                  borderColor:
                                      state.currentIndex == index
                                          ? Colors.white
                                          : state.answeredStatus[index]
                                          ? Colors.green
                                          : Colors.black,
                                  onTap:
                                      () => context.read<QuestionBloc>().add(
                                        JumpToQuestion(index),
                                      ),
                                ),
                              ),
                        ),
                      ),
                      10.hGap,
                      QuestionIndicator(
                        text: "Current",
                        fillColor: Colors.black,
                      ),
                      QuestionIndicator(
                        text: "Answered",
                        borderColor: Colors.green,
                        fillColor: Colors.white,
                      ),
                      QuestionIndicator(
                        text: "Not Answered",
                        fillColor: Colors.white,
                      ),
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

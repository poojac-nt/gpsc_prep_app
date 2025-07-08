import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/presentation/screens/home/widgets/custom_progress_bar.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test_event.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/timer/timer_event.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/widgets/question_indicator.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/widgets/question_navigator_btn.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import 'bloc/test_bloc.dart';
import 'bloc/test_state.dart';
import 'bloc/timer/timer_bloc.dart';
import 'bloc/timer/timer_state.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key, this.isFromResult = false});

  final bool isFromResult;

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List<String> indicator = ["Current", "Answered", "Not Answered"];

  late List<Question> questions;

  @override
  void initState() {
    // TODO: implement initState
    var bloc = context.read<TimerBloc>();
    if (widget.isFromResult) {
      bloc.add(TimerStop());
    } else {
      bloc.add(TimerStart());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daily Test", style: AppTexts.titleTextStyle),
        actions: [
          widget.isFromResult
              ? SizedBox.shrink()
              : Container(
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
                    BlocBuilder<TimerBloc, TimerState>(
                      builder: (context, state) {
                        if (state is TimerRunning) {
                          return Text(
                            "${state.remainingMinutes.toString().padLeft(2, '0')}:${state.remainingSeconds.toString().padLeft(2, '0')}",
                          );
                        }
                        if (state is TimerStopped) {
                          print(state.totalMins);
                          print(state.totalSecs);
                          return SizedBox.shrink();
                        }
                        return Text('00:00');
                      },
                    ),
                  ],
                ),
              ).padSymmetric(horizontal: 10.w),
        ],
      ),
      body: BlocConsumer<QuestionBloc, QuestionState>(
        listener: (context, state) {
          if (state is TestSubmitted && !state.isReview) {
            context.pushReplacement(AppRoutes.resultScreen);
          }
        },
        builder: (context, state) {
          print("Test$state");
          if (state is QuestionInitial) return Container();
          if (state is QuestionLoaded) {
            questions = state.questions;
            String? selectedAnswer = state.selectedOption[state.currentIndex];

            return PopScope(
              onPopInvokedWithResult: (didPop, _) {
                if (state.isReview) {
                  print('isreview called : ${state.isReview}');
                  context.read<QuestionBloc>().add(SubmitTest());
                }
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomProgressBar(
                      text:
                          "Question ${state.currentIndex + 1} of ${state.questions.length}",
                      value: state.progress,
                      percentageText: "${state.answered} Answered",
                    ),
                    20.hGap,
                    TestModule(
                      title: "Question ${state.currentIndex + 1}",
                      cards: [
                        state.question,
                        10.hGap,
                        ListView.builder(
                          itemCount: state.options.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final option = state.options[index];
                            final isSelected = selectedAnswer == option;
                            final correctAnswer =
                                state
                                    .questions[state.currentIndex]
                                    .correctAnswer;
                            final isCorrect = option == correctAnswer;
                            Color? tileColor;
                            if (state.isReview) {
                              if (isSelected && isCorrect) {
                                tileColor =
                                    Colors.green; // Correct answer selected
                              } else if (isSelected && !isCorrect) {
                                tileColor = Colors.red; // Wrong answer selected
                              } else if (isCorrect) {
                                tileColor =
                                    Colors.green; // Correct answer not selected
                              } else {
                                tileColor = Colors.transparent;
                              }
                            } else {
                              tileColor =
                                  isSelected
                                      ? AppColors.primary
                                      : AppColors.accentColor;
                            }

                            return BorderedContainer(
                              borderColor: tileColor,
                              padding: EdgeInsets.zero,
                              radius: BorderRadius.circular(10),
                              child: RadioListTile<String>(
                                value: option,
                                activeColor: AppColors.primary,
                                groupValue: selectedAnswer,
                                onChanged:
                                    state.isReview
                                        ? null
                                        : (value) {
                                          context.read<QuestionBloc>().add(
                                            AnswerQuestion(value!),
                                          );
                                        },
                                title: Text(
                                  option,
                                  style: TextStyle(
                                    color:
                                        state.isReview
                                            ? isCorrect
                                                ? Colors.green.shade700
                                                : isSelected && !isCorrect
                                                ? Colors.red.shade700
                                                : Colors.black
                                            : Colors.black,
                                  ),
                                ),
                              ),
                            ).padAll(5);
                          },
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
                                fontColor:
                                    state.currentIndex == 0
                                        ? Colors.grey
                                        : Colors.white,
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
                                          ? state.isReview
                                              ? "Back to Result"
                                              : "Submit Test"
                                          : "Next",
                                  onTap: () {
                                    if (state.currentIndex <
                                        state.questions.length - 1) {
                                      context.read<QuestionBloc>().add(
                                        NextQuestion(),
                                      );
                                    } else {
                                      if (!state.isReview) {
                                        context.read<TimerBloc>().add(
                                          TimerStop(),
                                        );
                                        context.read<QuestionBloc>().add(
                                          SubmitTest(),
                                        );
                                      } else {
                                        context.pop();
                                      }
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
                    state.isReview
                        ? TestModule(
                          title: "Explanation",
                          cards: [
                            Padding(
                              padding: EdgeInsets.only(left: 6.w),
                              child: Text(
                                state.questions[state.currentIndex].explanation,
                              ),
                            ),
                          ],
                        )
                        : SizedBox.shrink(),
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
                                            ? Colors.grey
                                            : state.answeredStatus[index]
                                            ? Colors.green
                                            : Colors.white,
                                    fontColor:
                                        state.currentIndex == index
                                            ? Colors.black
                                            : state.answeredStatus[index]
                                            ? Colors.white
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
                          text: "Attempted",
                          borderColor: Colors.green,
                          fillColor: Colors.green,
                        ),
                        QuestionIndicator(
                          text: "Visited",
                          borderColor: Colors.grey,
                          fillColor: Colors.grey,
                        ),
                        QuestionIndicator(
                          text: "Not Answered",
                          fillColor: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ).padAll(AppPaddings.defaultPadding),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}

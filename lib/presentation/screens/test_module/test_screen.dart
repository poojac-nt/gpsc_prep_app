import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:gpsc_prep_app/presentation/screens/home/widgets/custom_progress_bar.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/question/question_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test/test_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/timer/timer_event.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/widgets/question_indicator.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/widgets/question_navigator_btn.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/extensions/question_markdown.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'bloc/timer/timer_bloc.dart';
import 'bloc/timer/timer_state.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({
    super.key,
    this.isFromResult = false,
    required this.testId,
  });

  final int? testId;

  final bool isFromResult;

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List<String> indicator = ["Current", "Answered", "Not Answered"];
  final _snackBar = getIt<SnackBarHelper>();
  late QuestionLanguageData question;

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

  int totalTime(BuildContext context) {
    var timerState = context.read<TimerBloc>().state;
    int mins = timerState is TimerStopped ? timerState.totalMins : 0;
    int secs = timerState is TimerStopped ? timerState.totalSecs : 0;
    final timeSpent = (mins * 60) + secs;
    return timeSpent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BlocBuilder<QuestionBloc, QuestionState>(
          builder: (context, state) {
            if (state is! QuestionLoaded) return SizedBox.shrink();

            final isReviewMode = state.isReview;

            return IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if (!isReviewMode) {
                  // Show exit confirmation dialog during test
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Confirm Exit",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          "Do you really want to leave the test in between?",
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context.pop(); // Close dialog
                              context.pushReplacement(
                                AppRoutes.home,
                              ); // Go to home
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Yes, Leave",
                              style: AppTexts.title.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Just pop the screen if in review mode
                  context.pop();
                }
              },
            );
          },
        ),
        title: Text("Daily Test", style: AppTexts.titleTextStyle),
        actions: [
          if (!widget.isFromResult)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.black),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined, size: 18.sp),
                  SizedBox(width: 5.w),
                  BlocBuilder<TimerBloc, TimerState>(
                    builder: (context, state) {
                      if (state is TimerRunning) {
                        final minutes = state.remainingMinutes
                            .toString()
                            .padLeft(2, '0');
                        final seconds = state.remainingSeconds
                            .toString()
                            .padLeft(2, '0');
                        return Text('$minutes:$seconds');
                      } else if (state is TimerStopped) {
                        getIt<LogHelper>().w(state.totalMins.toString());
                        getIt<LogHelper>().w(state.totalSecs.toString());
                        return SizedBox.shrink();
                      } else {
                        return Text('00:00');
                      }
                    },
                  ),
                ],
              ),
            ).padAll(AppPaddings.appPaddingInt),
        ],
      ),
      body: BlocListener<TestBloc, TestState>(
        listener: (context, state) {
          if (state is TestSubmitted) {
            context.push(
              AppRoutes.resultScreen,
              extra: ResultScreenArgs(isFromTest: true, testId: widget.testId),
            );
          }
        },
        child: BlocBuilder<QuestionBloc, QuestionState>(
          builder: (context, state) {
            if (state is QuestionLoading) {
              return Padding(
                padding: EdgeInsets.all(AppPaddings.defaultPadding),
                child: Skeletonizer(
                  enabled: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fake progress bar
                      CustomProgressBar(
                        text: "Question 1 of 10",
                        value: 0.1,
                        percentageText: "0 Answered",
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

            if (state is QuestionLoadFailed) {
              _snackBar.showError(state.failure.message);
            }
            if (state is QuestionLoaded) {
              question = state.questions[state.currentIndex];
              String? selectedAnswer = state.selectedOption[state.currentIndex];
              return PopScope(
                onPopInvokedWithResult: (didPop, _) {
                  if (state.isReview) {
                    getIt<LogHelper>().w('isReview called : ${state.isReview}');
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
                          state.questions[state.currentIndex].questionTxt
                              .toQuestionWidget(),
                          10.hGap,
                          ListView.builder(
                            itemCount: state.options.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final option = state.options[index];
                              final isSelected = selectedAnswer == option;
                              Color? tileColor;
                              Color? textColor;

                              final correctAnswer =
                                  state
                                      .questions[state.currentIndex]
                                      .correctAnswer;

                              if (state.isReview) {
                                if (isSelected && option == correctAnswer) {
                                  tileColor = Colors.green;
                                  // Selected and correct
                                  textColor = Colors.green.shade700;
                                } else if (isSelected &&
                                    option != correctAnswer) {
                                  // Selected and wrong
                                  tileColor = Colors.red;
                                  textColor = Colors.red.shade700;
                                } else if (!isSelected &&
                                    option == correctAnswer) {
                                  // Not selected, but correct answer
                                  tileColor = Colors.green.withOpacity(0.3);
                                  textColor = Colors.green.shade800;
                                } else {
                                  tileColor = Colors.transparent;
                                  textColor = Colors.black;
                                }
                              } else {
                                tileColor =
                                    isSelected
                                        ? AppColors.primary
                                        : AppColors.accentColor;
                                textColor = Colors.black;
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
                                              ? textColor
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
                                  backgroundColor:
                                      state.currentIndex == 0
                                          ? Colors.grey
                                          : AppColors.primary,
                                  text: "Previous",
                                  onTap: () {
                                    state.currentIndex > 0
                                        ? context.read<QuestionBloc>().add(
                                          PrevQuestion(),
                                        )
                                        : null;
                                  },
                                  fontColor: Colors.white,
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
                                          var time = totalTime(context);
                                          _buildSubmitDialoge(
                                            context,
                                            state,
                                            time,
                                          );
                                        } else {
                                          context.pop(); // Go back from review
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
                                child:
                                    state
                                        .questions[state.currentIndex]
                                        .explanation
                                        .toQuestionWidget(),
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
                                          () => context
                                              .read<QuestionBloc>()
                                              .add(JumpToQuestion(index)),
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
      ),
    );
  }

  void _buildSubmitDialoge(
    BuildContext context,
    QuestionLoaded state,
    int timeTaken,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final total = state.questions.length;
        final attempted = state.answeredStatus.where((status) => status).length;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                "Submit Test",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You have attempted $attempted out of $total questions.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Are you sure you want to submit the test?",
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ],
          ),
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
                print("Test id ${widget.testId}");
                context.read<TestBloc>().add(
                  SubmitTest(
                    widget.testId!,
                    total,
                    state.questions,
                    state.selectedOption,
                    state.answeredStatus,
                    timeTaken,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

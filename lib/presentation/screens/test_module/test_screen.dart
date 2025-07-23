import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/widgets/custom_progress_bar.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/question/question_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test/test_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test/test_event.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/timer/timer_event.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/question/question_cubit.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/question/question_cubit_state.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/test/test_cubit.dart';
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
import 'cubit/test/test_cubit_state.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({
    super.key,
    this.isFromResult = false,
    required this.testId,
    required this.testName,
    required this.testDuration,
    required this.language,
  });

  final bool isFromResult;
  final String? language;
  final int? testId;
  final String testName;
  final int? testDuration;

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late QuestionLanguageData question;
  bool _initialized = false;

  @override
  void initState() {
    final bloc = context.read<TimerBloc>();
    if (widget.isFromResult) {
      bloc.add(TimerStop());
    } else {
      context.read<QuestionBloc>().add(
        LoadQuestion(widget.testId!, widget.language),
      );
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
    return BlocListener<TimerBloc, TimerState>(
      listener: (context, state) {
        if (state is TimerStopped) {
          // Get data from QuestionCubit
          final questionCubitState = context.read<QuestionCubit>().state;
          if (questionCubitState is! QuestionCubitLoaded) return;

          // Get data from QuestionBloc
          final questionBlocState = context.read<QuestionBloc>().state;
          if (questionBlocState is! QuestionLoaded) return;

          context.read<TestCubit>().calculateAndEmitTestResult(
            questions: questionCubitState.questions,
            selectedOption: questionCubitState.selectedOption,
            answeredStatus: questionCubitState.answeredStatus,
            marks: questionBlocState.marks,
            minSpent: state.totalMins,
            secSpent: state.totalSecs,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: Text(widget.testName, style: AppTexts.titleTextStyle),
          ),
          actions: [
            widget.isFromResult
                ? SizedBox.shrink()
                : Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 3.h,
                  ),
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
                            return SizedBox(
                              width: 43.w,
                              child: Text(
                                "${state.remainingMinutes.toString().padLeft(2, '0')}:${state.remainingSeconds.toString().padLeft(2, '0')}",
                              ),
                            );
                          }
                          if (state is TimerStopped) {
                            getIt<LogHelper>().w(state.totalMins.toString());
                            getIt<LogHelper>().w(state.totalSecs.toString());
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
        body: BlocListener<TestCubit, TestCubitSubmitted>(
          listener: (context, state) {
            context.read<TestBloc>().add(
              SubmitTest(
                widget.testId!,
                state.questions,
                state.selectedOption,
                state.answeredStatus,
                state.totalQuestions,
                state.correctAnswers,
                state.inCorrectAnswers,
                state.attemptedQuestions,
                state.notAttemptedQuestions,
                state.score,
                state.timeSpent,
              ),
            );
            final timerState = context.read<TimerBloc>().state;
            final questionCubitState = context.read<QuestionCubit>().state;

            if (timerState is TimerStopped && !timerState.isManual) {
              _buildAutoSubmitDialog(context, state);
            } else if (questionCubitState is QuestionCubitLoaded &&
                questionCubitState.isQuitTest) {
              context.go(AppRoutes.dashboard);
            } else {
              context.pushReplacement(
                AppRoutes.resultScreen,
                extra: ResultScreenArgs(
                  isFromTest: true,
                  testName: widget.testName,
                  testId: widget.testId,
                ),
              );
            }
          },
          child: BlocConsumer<QuestionBloc, QuestionState>(
            listener: (context, state) {
              if (state is QuestionLoaded && !_initialized) {
                _initialized = true;

                if (widget.isFromResult) {
                  context.read<QuestionCubit>().initialize(state.questions);
                } else {
                  context.read<QuestionCubit>()
                    ..reset()
                    ..initialize(state.questions);
                  context.read<TimerBloc>().add(
                    TimerStart(testDuration: widget.testDuration),
                  );
                }
              }
            },
            builder: (context, state) {
              if (state is QuestionLoading) {
                return _buildWhenLoading();
              }

              if (state is QuestionLoaded) {
                final marks = state.marks;
                final subjects = state.subjects;
                final topics = state.topics;
                final difficultyLevel = state.difficultyLevel;
                return BlocBuilder<QuestionCubit, QuestionCubitState>(
                  builder: (context, state) {
                    if (state is! QuestionCubitLoaded) {
                      return SizedBox.shrink();
                    }
                    final currentIndex = state.currentIndex;
                    final question = state.questions[currentIndex];
                    final selectedAnswer = state.selectedOption[currentIndex];
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          CustomProgressBar(
                            text:
                                "Question ${state.currentIndex + 1} of ${state.questions.length}",
                            value: state.progress,
                            percentageText: "${state.answered} Answered",
                          ),
                          20.hGap,
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                state.isReview
                                    ? SizedBox.shrink()
                                    : Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 25.w),
                                        child: ActionButton(
                                          text: "Quit Test",
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (context) => customDialogBox(
                                                    context,
                                                    "Confirm Exit",
                                                    "Do you really want to leave the test in between?",
                                                    "Your answers so far will be saved, you won’t be able to resume this test later.",
                                                    [
                                                      TextButton(
                                                        child: Text(
                                                          "Cancel",
                                                          style: TextStyle(
                                                            color:
                                                                Colors
                                                                    .grey[700],
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(
                                                            context,
                                                          ).pop(); // Close dialog
                                                        },
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.redAccent,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          "Yes, Leave",
                                                          style: AppTexts.title
                                                              .copyWith(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                        ),
                                                        onPressed: () {
                                                          context
                                                              .pop(); // Close dialog
                                                          context
                                                              .read<
                                                                QuestionCubit
                                                              >()
                                                              .markAsQuit();
                                                          context
                                                              .read<TimerBloc>()
                                                              .add(TimerStop());
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                100.wGap,
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: state.isReview ? 98.w : 8.w,
                                    ),
                                    child: ActionButton(
                                      text:
                                          state.isReview
                                              ? "Back to Result"
                                              : "Submit Test",
                                      onTap: () {
                                        if (!state.isReview) {
                                          var time = totalTime(context);
                                          _buildSubmitDialog(
                                            context,
                                            state,
                                            time,
                                            marks,
                                          );
                                        } else {
                                          context.pop();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          20.hGap,
                          TestModule(
                            title: "Question ${state.currentIndex + 1}",
                            cards: [
                              question.questionTxt.toQuestionWidget(),
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

                                  final correctAnswer = question.correctAnswer;

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
                                      toggleable: true,
                                      activeColor: AppColors.primary,
                                      groupValue: selectedAnswer,
                                      onChanged:
                                          state.isReview
                                              ? null
                                              : (value) {
                                                context
                                                    .read<QuestionCubit>()
                                                    .answerQuestion(value);
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                            ? context
                                                .read<QuestionCubit>()
                                                .prevQuestion()
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
                                        text: "Next",
                                        backgroundColor:
                                            state.currentIndex ==
                                                    state.questions.length - 1
                                                ? Colors.grey
                                                : AppColors.primary,
                                        onTap: () {
                                          state.currentIndex <
                                                  state.questions.length - 1
                                              ? context
                                                  .read<QuestionCubit>()
                                                  .nextQuestion()
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
                          state.isReview
                              ? TestModule(
                                title: "Explanation",
                                cards: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 6.w),
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Subject: ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                          TextSpan(
                                            text: subjects[state.currentIndex],
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 6.w),
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Topic: ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                          TextSpan(
                                            text: topics[state.currentIndex],
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 6.w),
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Difficulty Level: ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                difficultyLevel[state
                                                        .currentIndex]
                                                    .level,
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
                                                  ? state.isReview
                                                      ? state.isCorrect![index] ==
                                                              false
                                                          ? Colors.red
                                                          : Colors.green
                                                      : Colors.black
                                                  : Colors.white,
                                          fontColor:
                                              state.currentIndex == index
                                                  ? Colors.black
                                                  : state.answeredStatus[index]
                                                  ? Colors.white
                                                  : Colors.black,
                                          borderColor:
                                              state.currentIndex == index
                                                  ? Colors.grey
                                                  : state.answeredStatus[index]
                                                  ? state.isReview
                                                      ? state.isCorrect![index] ==
                                                              false
                                                          ? Colors.red
                                                          : Colors.green
                                                      : Colors.black
                                                  : Colors.black,
                                          onTap:
                                              () => context
                                                  .read<QuestionCubit>()
                                                  .jumpToQuestion(index),
                                        ),
                                      ),
                                ),
                              ),
                              10.hGap,
                              QuestionIndicator(
                                text: state.isReview ? "Correct" : "Attempted",
                                borderColor:
                                    state.isReview
                                        ? Colors.green
                                        : Colors.black,
                                fillColor:
                                    state.isReview
                                        ? Colors.green
                                        : Colors.black,
                              ),
                              state.isReview
                                  ? QuestionIndicator(
                                    text: "Incorrect",
                                    borderColor: Colors.red,
                                    fillColor: Colors.red,
                                  )
                                  : SizedBox.shrink(),
                              QuestionIndicator(
                                text: "Not Attempted",
                                fillColor: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ).padAll(AppPaddings.defaultPadding),
                    );
                  },
                );
              }
              return Container();
            },
          ),
        ),
      ),
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
        return customDialogBox(
          context,
          "Submit Test",
          "You have attempted $attempted out of $total questions.",
          "Are you sure you want to submit the test?",
          [
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

  Widget customDialogBox(
    BuildContext context,
    String title,
    String mainContent,
    String content,
    List<Widget> actions,
  ) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mainContent,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Text(content, style: TextStyle(fontSize: 15, color: Colors.black54)),
        ],
      ),
      actions: actions,
    );
  }

  void _buildAutoSubmitDialog(BuildContext context, TestCubitSubmitted state) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        final total = state.totalQuestions;
        final attempted = state.answeredStatus.where((status) => status).length;
        return customDialogBox(
          context,
          "Time is over",
          "You have attempted $attempted out of $total questions.",
          'Your time for this test has ended. Submitting your answers now and showing your results.',
          [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "View Result",
                style: AppTexts.title.copyWith(color: Colors.white),
              ),
              onPressed: () {
                context.pop(); // close dialog
                context.pushReplacement(
                  AppRoutes.resultScreen,
                  extra: ResultScreenArgs(
                    isFromTest: true,
                    testId: widget.testId,
                    testName: widget.testName,
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

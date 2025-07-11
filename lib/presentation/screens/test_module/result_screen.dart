import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/question/question_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test/test_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/timer/timer_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/timer/timer_state.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, this.isFromTestScreen = false, this.testId});

  final bool isFromTestScreen;
  final int? testId;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();

    if (!widget.isFromTestScreen && widget.testId != null) {
      context.read<TestBloc>().add(
        FetchSingleTestResultEvent(testId: widget.testId!),
      );
    }
  }

  String formatTimeSpent(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    String minutesPart = mins > 0 ? '$mins' : '';
    String secondsPart = secs > 0 ? '$secs' : '';
    if (minutesPart.isEmpty && secondsPart.isEmpty) return '0 sec';
    return '$minutesPart${minutesPart.isNotEmpty && secondsPart.isNotEmpty ? ' ' : '0'}:$secondsPart';
  }

  final List<String> containerTitle = [
    'Correct',
    'InCorrect',
    'Not Attempted',
    'Attempted',
    'Time Taken',
    'Total Questions',
  ];

  final List<Color> containerColors = [
    Colors.green.shade500,
    Colors.red.shade500,
    Colors.blueGrey.shade500,
    Colors.purple.shade500,
    Colors.blue.shade500,
    Colors.cyan.shade500,
  ];

  String totalTime(BuildContext context) {
    var timerState = context.read<TimerBloc>().state;
    int mins = timerState is TimerStopped ? timerState.totalMins : 0;
    int secs = timerState is TimerStopped ? timerState.totalSecs : 0;
    var timeSpent = "$mins:$secs";
    return timeSpent;
  }

  @override
  Widget build(BuildContext context) {
    var time = totalTime(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        context.go(AppRoutes.home);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Test Completed', style: AppTexts.titleTextStyle),
        ),
        body: SingleChildScrollView(
          child: BlocBuilder<TestBloc, TestState>(
            builder: (context, state) {
              print("state of result screen :${state.runtimeType}");
              if (state is TestSubmitted) {
                final List<String> containerValues = [
                  state.correct.toString(),
                  state.inCorrect.toString(),
                  state.notAttempted.toString(),
                  state.attempted.toString(),
                  time,
                  state.totalQuestions.toString(),
                ];
                return TestModule(
                  iconSize: 26.sp,
                  fontSize: 26.sp,
                  title: "Test Result",
                  cards: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            '0%',
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Your Score",
                            style: AppTexts.subTitle.copyWith(fontSize: 14.sp),
                          ),
                        ],
                      ),
                    ),
                    20.hGap,
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemCount: containerTitle.length,
                      itemBuilder:
                          (context, index) => containerWidget(
                            containerValues[index],
                            containerTitle[index],
                            containerColors[index],
                          ),
                    ),
                    20.hGap,
                    Column(
                      children: [
                        ActionButton(
                          text: "Download Detailed Report",
                          onTap: () {},
                        ),
                        5.hGap,
                        ActionButton(
                          text: "Review Answers",
                          fontColor: Colors.white,
                          onTap: () {
                            context.read<QuestionBloc>().add(
                              ReviewTestEvent(
                                state.questions,
                                state.selectedOption,
                                state.answeredStatus,
                                state.isCorrect,
                              ),
                            );
                            context.push(
                              AppRoutes.testScreen,
                              extra: TestScreenArgs(
                                isFromResult: true,
                                testId: null,
                              ), // or testId: 123
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                  prefixIcon: Icons.check_circle_outline_sharp,
                  iconColor: Colors.green,
                ).padAll(AppPaddings.defaultPadding);
              }
              if (state is SingleResultSuccess) {
                final List<String> containerValues = [
                  state.result.correctAnswers.toString(),
                  state.result.inCorrectAnswers.toString(),
                  state.result.notAttemptedQuestions.toString(),
                  state.result.attemptedQuestions.toString(),
                  formatTimeSpent(state.result.timeTaken),
                  state.result.totalMarks.toString(),
                ];
                return TestModule(
                  iconSize: 26.sp,
                  fontSize: 26.sp,
                  title: "Test Result",
                  cards: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            '0%',
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Your Score",
                            style: AppTexts.subTitle.copyWith(fontSize: 14.sp),
                          ),
                        ],
                      ),
                    ),
                    20.hGap,
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemCount: containerTitle.length,
                      itemBuilder:
                          (context, index) => containerWidget(
                            containerValues[index],
                            containerTitle[index],
                            containerColors[index],
                          ),
                    ),
                    20.hGap,
                    // Column(
                    //   children: [
                    //     ActionButton(
                    //       text: "Download Detailed Report",
                    //       onTap: () {},
                    //     ),
                    //     5.hGap,
                    //     ActionButton(
                    //       text: "Review Answers",
                    //       fontColor: Colors.white,
                    //       onTap: () {
                    //
                    //         context.read<QuestionBloc>().add(
                    //           ReviewTestEvent(
                    //             state.questions,
                    //             state.selectedOption,
                    //             state.answeredStatus,
                    //             state.isCorrect,
                    //           ),
                    //         );
                    //         context.push(
                    //           AppRoutes.testScreen,
                    //           extra: TestScreenArgs(
                    //             isFromResult: true,
                    //             testId: null,
                    //           ), // or testId: 123
                    //         );
                    //       },
                    //     ),
                    //   ],
                    // ),
                  ],
                  prefixIcon: Icons.check_circle_outline_sharp,
                  iconColor: Colors.green,
                ).padAll(AppPaddings.defaultPadding);
              }
              return SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget containerWidget(String value, String title, Color containerColor) {
    return BorderedContainer(
      hasBorder: false,
      backgroundColor: Color.lerp(containerColor, Colors.white, 0.8)!,
      padding: EdgeInsets.all(10.sp),
      radius: BorderRadius.circular(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: AppTexts.labelTextStyle.copyWith(
              color: containerColor,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Wrap(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                softWrap: true,
                style: AppTexts.subTitle.copyWith(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

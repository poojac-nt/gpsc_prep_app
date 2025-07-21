import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/blocs/connectivity_bloc/connectivity_bloc.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test/test_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/timer/timer_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/timer/timer_state.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/question/question_cubit.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/test/test_cubit.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/test/test_cubit_state.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import 'bloc/test/test_event.dart';
import 'bloc/test/test_state.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    this.isFromTestScreen = false,
    this.testId,
    this.testName,
  });

  final bool isFromTestScreen;
  final int? testId;
  final String? testName;

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
    if (minutesPart.isEmpty && secondsPart.isEmpty) return '0';
    return '$minutesPart${minutesPart.isNotEmpty ? '' : '0'}:$secondsPart${secondsPart.isNotEmpty ? ' ' : '0'}';
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
    final timerState = context.read<TimerBloc>().state;
    int mins = timerState is TimerStopped ? timerState.totalMins : 0;
    int secs = timerState is TimerStopped ? timerState.totalSecs : 0;
    final timeSpent = "$mins:$secs";
    return timeSpent;
  }

  @override
  Widget build(BuildContext context) {
    var time = totalTime(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        context.read<ConnectivityBloc>().add(CheckConnectivity());
        context.go(AppRoutes.dashboard);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Test Completed', style: AppTexts.titleTextStyle),
        ),
        body: SingleChildScrollView(
          child: BlocBuilder<TestBloc, TestState>(
            builder: (context, state) {
              if (state is TestSubmitted) {
                return BlocBuilder<TestCubit, TestCubitSubmitted>(
                  builder: (context, state) {
                    final List<String> containerValues = [
                      state.correctAnswers.toString(),
                      state.inCorrectAnswers.toString(),
                      state.notAttemptedQuestions.toString(),
                      state.attemptedQuestions.toString(),
                      time,
                      state.totalQuestions.toString(),
                    ];
                    return TestModule(
                      iconSize: 26.sp,
                      fontSize: 26.sp,
                      title: "${widget.testName} Result",
                      cards: [
                        Center(
                          child: Column(
                            children: [
                              Text(
                                state.score!.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Your Score",
                                style: AppTexts.subTitle.copyWith(
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        20.hGap,
                        GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                                context.read<QuestionCubit>().reviewTest(
                                  questions: state.questions,
                                  isCorrect: state.isAnswerCorrect,
                                  answeredStatus: state.answeredStatus,
                                  selectedOption: state.selectedOption,
                                );
                                context.push(
                                  AppRoutes.testScreen,
                                  extra: TestScreenArgs(
                                    isFromResult: true,
                                    testId: null,
                                    testDuration: null,
                                    testName: widget.testName!,
                                    language: null,
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
                  },
                );
              }
              if (state is SingleResultSuccess) {
                final List<String> containerValues = [
                  state.result.correctAnswers.toString(),
                  state.result.inCorrectAnswers.toString(),
                  state.result.notAttemptedQuestions.toString(),
                  state.result.attemptedQuestions.toString(),
                  formatTimeSpent(state.result.timeTaken),
                  state.result.totalQuestions.toString(),
                ];
                return TestModule(
                  iconSize: 26.sp,
                  fontSize: 26.sp,
                  title: "${widget.testName!} Result",
                  cards: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            state.result.score.toStringAsFixed(2),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test_event.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test_state.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import 'bloc/test_bloc.dart';

class ResultScreen extends StatelessWidget {
  ResultScreen({super.key});

  final List<String> containerTitle = [
    'Correct',
    'InCorrect',
    'Not Attempted',
    'Attempted',
    'Time Spent',
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        context.pushReplacement(AppRoutes.home);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Test Completed', style: AppTexts.titleTextStyle),
        ),
        body: SingleChildScrollView(
          child: BlocBuilder<QuestionBloc, QuestionState>(
            builder: (context, state) {
              if (state is QuestionInitial) {
                return Center(child: CircularProgressIndicator());
              } else if (state is TestSubmitted) {
                final List<String> containerValues = [
                  state.correct.toString(),
                  state.inCorrect.toString(),
                  state.notAttempted.toString(),
                  state.attempted.toString(),
                  state.timeSpent.toString(),
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
                            context.push(AppRoutes.testScreen);
                            context.read<QuestionBloc>().add(
                              ReviewTestMode(
                                state.questions,
                                state.selectedOption,
                                state.answeredStatus,
                              ),
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
              return Container();
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

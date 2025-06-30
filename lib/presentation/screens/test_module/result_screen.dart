import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test_state.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import 'bloc/test_bloc.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Completed', style: AppTexts.titleTextStyle),
      ),
      body: SingleChildScrollView(
        child: BlocBuilder<QuestionBloc, QuestionState>(
          builder: (context, state) {
            if (state is QuestionInitial) {
              return Center(child: CircularProgressIndicator());
            } else if (state is QuestionLoaded) {
              var notAttempted =
                  state.answeredStatus.where((value) => !value).toList().length;

              var attempted =
                  state.answeredStatus.where((value) => value).toList().length;

              var timeSpent = 30 - (state.tickCount ~/ 60);
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
                  Column(
                    children: [
                      Row(
                        children: [
                          BorderedContainer(
                            backgroundColor: Colors.green[50],
                            radius: BorderRadius.zero,
                            padding: EdgeInsets.symmetric(
                              horizontal: 13.w,
                              vertical: 13.h,
                            ),
                            borderColor: Colors.green,
                            child: Column(
                              children: [
                                Text(
                                  "1",
                                  style: AppTexts.labelTextStyle.copyWith(
                                    color: Colors.green,
                                    fontSize: 26.sp,
                                  ),
                                ),
                                Text(
                                  "Correctttt \n",
                                  textAlign: TextAlign.center,
                                  style: AppTexts.subTitle.copyWith(
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          10.wGap,
                          BorderedContainer(
                            backgroundColor: Colors.red[50],
                            radius: BorderRadius.zero,
                            padding: EdgeInsets.symmetric(
                              horizontal: 13.w,
                              vertical: 13.h,
                            ),
                            borderColor: Colors.red,
                            child: Column(
                              children: [
                                Text(
                                  "2",
                                  style: AppTexts.labelTextStyle.copyWith(
                                    color: Colors.red,
                                    fontSize: 26.sp,
                                  ),
                                ),
                                Text(
                                  "Incorrect \n",
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: AppTexts.subTitle.copyWith(
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          10.wGap,
                          BorderedContainer(
                            backgroundColor: Colors.blueGrey[50],
                            radius: BorderRadius.zero,
                            padding: EdgeInsets.symmetric(
                              horizontal: 15.w,
                              vertical: 16.h,
                            ),
                            borderColor: Colors.blueGrey,
                            child: Column(
                              children: [
                                Text(
                                  notAttempted.toString(),
                                  maxLines: 2,
                                  style: AppTexts.labelTextStyle.copyWith(
                                    color: Colors.blueGrey,
                                    fontSize: 26.sp,
                                  ),
                                ),
                                Text(
                                  "Not \nAttempted",
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: AppTexts.subTitle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      10.hGap,
                      Row(
                        children: [
                          BorderedContainer(
                            backgroundColor: Colors.deepPurple[50],
                            radius: BorderRadius.zero,
                            padding: EdgeInsets.symmetric(
                              horizontal: 11.w,
                              vertical: 11.h,
                            ),
                            borderColor: Colors.deepPurple,
                            child: Column(
                              children: [
                                Text(
                                  attempted.toString(),
                                  style: AppTexts.labelTextStyle.copyWith(
                                    color: Colors.deepPurple,
                                    fontSize: 26.sp,
                                  ),
                                ),
                                Text(
                                  "Attempted \n",
                                  textAlign: TextAlign.center,
                                  style: AppTexts.subTitle.copyWith(
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          10.wGap,
                          BorderedContainer(
                            backgroundColor: Colors.blue[50],
                            radius: BorderRadius.zero,
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.w,
                              vertical: 10.h,
                            ),
                            borderColor: Colors.blueAccent,
                            child: Column(
                              children: [
                                Text(
                                  "${timeSpent.toString().padLeft(2, '0')}",
                                  style: AppTexts.labelTextStyle.copyWith(
                                    color: Colors.blueAccent,
                                    fontSize: 26.sp,
                                  ),
                                ),
                                Text(
                                  "Time Spent \n",
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: AppTexts.subTitle.copyWith(
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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
                        borderColor: Colors.black,
                        fontColor: Colors.black,
                        backColor: Colors.white,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
                icon: Icons.check_circle_outline_sharp,
                iconColor: Colors.green,
              ).padAll(AppPaddings.defaultPadding);
            }
            return Container();
          },
        ),
      ),
    );
  }
}

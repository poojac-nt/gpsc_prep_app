import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_tile.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'bloc/daily_test_bloc.dart';
import 'bloc/daily_test_event.dart';
import 'bloc/daily_test_state.dart';

class MCQTestScreen extends StatefulWidget {
  const MCQTestScreen({super.key});

  @override
  State<MCQTestScreen> createState() => _MCQTestScreenState();
}

class _MCQTestScreenState extends State<MCQTestScreen> {
  @override
  void initState() {
    context.read<DailyTestBloc>().add(FetchTests());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MCQ Tests", style: AppTexts.titleTextStyle),
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Icon(CupertinoIcons.bell_fill, color: Colors.black),
          ),
        ],
      ),
      body: BlocConsumer<DailyTestBloc, DailyTestState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is DailyTestFetching) {
            return Padding(
              padding: EdgeInsets.all(AppPaddings.appPaddingInt),
              child: Skeletonizer(
                enabled: true,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Your loading skeletons go here (if needed)
                    ],
                  ),
                ),
              ),
            );
          } else if (state is DailyTestFetchFailed) {
            return Center(child: Text(state.failure.message));
          } else if (state is DailyTestFetched) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Available Tests', style: AppTexts.heading),
                      IntrinsicWidth(
                        child: ActionButton(
                          text: 'Generate Test',
                          onTap: () {
                            // Handle Generate Test
                          },
                        ),
                      ),
                    ],
                  ),
                  10.hGap,

                  /// Daily Tests Section
                  TestModule(
                    title: "Daily Tests",
                    subtitle: "Subject-based Daily Practice",
                    prefixIcon: Icons.calendar_today_outlined,
                    cards: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: state.dailyTestModel.length,
                        itemBuilder: (context, index) {
                          final test = state.dailyTestModel[index];
                          final hasResult = state.testResults.containsKey(
                            test.id,
                          );
                          return TestTile(
                            title: test.name,
                            subtitle:
                                "${test.noQuestions} Questions · ${test.duration} min",
                            onTap: () {
                              if (hasResult) {
                                context.push(
                                  AppRoutes.resultScreen,
                                  extra: ResultScreenArgs(
                                    isFromTest: false,
                                    testId: test.id,
                                  ),
                                );
                              } else {
                                context.pushReplacement(
                                  AppRoutes.testInstructionScreen,
                                  extra: TestInstructionScreenArgs(
                                    testId: test.id,
                                    availableLanguages:
                                        state.languages[test.id] ?? {'en'},
                                  ), // or testId: 123
                                );
                              }
                            },
                            buttonTitle: hasResult ? 'Result' : 'Start',
                          ).padSymmetric(vertical: 6.h);
                        },
                      ),
                    ],
                  ),
                  10.hGap,

                  /// Mock Tests Section
                  TestModule(
                    title: "Mock Tests",
                    subtitle: "Full Length Practice Exams",
                    prefixIcon: Icons.description_outlined,
                    cards: [
                      TestTile(
                        title: "GPSC Mock Test #1",
                        subtitle: "100 Questions · 2 hours",
                        widgets: [
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Icon(
                              Icons.file_download_outlined,
                              color: Colors.black,
                            ),
                          ),
                        ],
                        onTap: () {
                          // Handle mock test tap
                        },
                        buttonTitle: 'Start',
                      ),
                    ],
                  ),
                  10.hGap,

                  /// Offline Mode Section
                  TestModule(
                    title: 'Offline Mode',
                    subtitle: 'Download tests for offline Practice',
                    prefixIcon: Icons.file_download_outlined,
                    cards: [
                      BorderedContainer(
                        borderColor: AppColors.accentColor,
                        padding: EdgeInsets.all(5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.file_download_outlined),
                            10.wGap,
                            Text('Download PDF Test', style: AppTexts.title),
                          ],
                        ),
                      ),
                      10.hGap,
                      BorderedContainer(
                        borderColor: AppColors.accentColor,
                        padding: EdgeInsets.all(5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.file_upload_outlined),
                            10.wGap,
                            Text('Upload Answers', style: AppTexts.title),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ).padAll(AppPaddings.appPaddingInt),
            );
          }
          return Container(); // fallback UI for unhandled states
        },
      ),
    );
  }
}

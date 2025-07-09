import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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
    context.read<DailyTestBloc>().add(FetchDailyTest());
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Available Tests', style: AppTexts.heading),
                          IntrinsicWidth(
                            child: ActionButton(
                              text: 'Generate Test',
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      10.hGap,
                      // Fake Daily Tests Section
                      TestModule(
                        title: "Daily Tests",
                        subtitle: "Subject-based Daily Practice",
                        prefixIcon: Icons.calendar_today_outlined,
                        cards: List.generate(
                          3,
                          (index) => Skeleton.ignorePointer(
                            child: TestTile(
                              title: "Test Title Placeholder",
                              onTap: () {},
                              buttonTitle: "Start",
                            ).padSymmetric(vertical: 6.h),
                          ),
                        ),
                      ),
                      10.hGap,
                      // Fake Mock Tests Section
                      TestModule(
                        title: "Mock Tests",
                        subtitle: "Full Length practice Exams",
                        prefixIcon: Icons.description_outlined,
                        cards: [
                          TestTile(
                            title: "Mock Test Placeholder",
                            subtitle: "100 Questions . 2 hours",
                            widgets: [
                              Skeleton.shade(
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Icon(
                                    Icons.file_download_outlined,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                            onTap: () {},
                            buttonTitle: 'Start',
                          ),
                        ],
                      ),
                      10.hGap,
                      // Fake Offline Mode Section
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
                                Text(
                                  'Download PDF Test',
                                  style: AppTexts.title,
                                ),
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
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  10.hGap,
                  // Daily Tests Section
                  TestModule(
                    title: "Daily Tests",
                    subtitle: "Subject-based Daily Practice",
                    prefixIcon: Icons.calendar_today_outlined,
                    cards: [
                      ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: state.dailyTestModel.length,
                        itemBuilder:
                            (context, index) => TestTile(
                              title: state.dailyTestModel[index].name,
                              onTap:
                                  () => context.pushReplacement(
                                    AppRoutes.testInstructionScreen,
                                    extra: state.dailyTestModel[index].id,
                                  ),
                              buttonTitle: 'Start',
                            ).padSymmetric(vertical: 6.h),
                      ),
                    ],
                  ),
                  10.hGap,
                  // Mock Tests Section
                  TestModule(
                    title: "Mock Tests",
                    subtitle: "Full Length practice Exams",
                    prefixIcon: Icons.description_outlined,
                    cards: [
                      TestTile(
                        title: "GPSC Mock Test #1",
                        subtitle: "100 Questions . 2 hours",
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
                        onTap: () {},
                        buttonTitle: 'Start',
                      ),
                    ],
                  ),
                  10.hGap,
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
          return Container();
        },
      ),
    );
  }
}

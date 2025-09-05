import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/icons/icons.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_tile.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../blocs/daily test/daily_test_bloc.dart';
import '../../blocs/daily test/daily_test_event.dart';
import '../../blocs/daily test/daily_test_state.dart';

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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("MCQ Tests", style: AppTexts.titleTextStyle),
          centerTitle: false,
          bottom: TabBar(
            tabAlignment: TabAlignment.center,
            padding: EdgeInsets.zero,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.black54,
            labelStyle: AppTexts.titleTextStyle.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: AppTexts.titleTextStyle.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 14.sp,
            ),
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 3, color: AppColors.primary),
              insets: EdgeInsets.symmetric(horizontal: 16.w),
            ),
            indicatorSize: TabBarIndicatorSize.label,
            labelPadding: EdgeInsets.symmetric(
              horizontal: 18.w,
              vertical: 10.h,
            ),
            tabs: const [
              Tab(text: "All Subjects"),
              Tab(text: "Current Affairs"),
              Tab(text: "Math"),
            ],
          ),
        ),
        body: BlocConsumer<DailyTestBloc, DailyTestState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is DailyTestFetching) {
              return _buildWhenLoading();
            } else if (state is DailyTestFetched) {
              final tests = state.dailyTestModel;

              return TabBarView(
                children: [
                  _buildFilteredList(tests, null, state), // all subjects
                  _buildFilteredList(tests, "Current Affairs", state),
                  _buildFilteredList(tests, "Math", state),
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  /// Build filtered list for each tab
  Widget _buildFilteredList(
    List tests,
    String? filter,
    DailyTestFetched state,
  ) {
    final filtered =
        filter == null
            ? tests
            : tests
                .where(
                  (t) => t.name.toLowerCase().contains(filter.toLowerCase()),
                )
                .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text("No tests available for ${filter ?? "All Subjects"}"),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          ...filtered.map((test) {
            final testResult = state.testResults[test.id];
            final hasResult = testResult != null;

            // Default values
            DateTime? submittedAt;
            bool isEligibleForRetest = false;

            if (hasResult) {
              final createdAtString = testResult.createdAt;
              if (createdAtString != null && createdAtString.isNotEmpty) {
                try {
                  submittedAt = DateTime.parse(createdAtString);
                  isEligibleForRetest =
                      DateTime.now().difference(submittedAt).inHours >= 12;
                } catch (e) {
                  // ignore parse error
                }
              }
            }

            return Column(
              children: [
                TestModule(
                  showShareButton: true,
                  testModel: test,
                  title: "Daily Tests",
                  subtitle: "Subject-based Daily Practice",
                  prefixIcon: Icons.calendar_today_outlined,
                  cards: [
                    TestTile(
                      title: test.name,
                      subtitle:
                          "${test.noQuestions} Questions · ${test.duration} min",
                      onTap: () {
                        if (hasResult) {
                          context.pushReplacement(
                            AppRoutes.resultScreen,
                            extra: ResultScreenArgs(
                              isFromTest: false,
                              dailyTestModel: test,
                            ),
                          );
                        } else {
                          context.pushReplacementNamed(
                            AppRoutes.testInstructionScreen,
                            extra: TestInstructionScreenArgs(
                              dailyTestModel: test,
                            ),
                          );
                        }
                      },
                      hasResult: hasResult,
                      widgets:
                          hasResult && isEligibleForRetest
                              ? [
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        AppIcons.retest_icon,
                                        color: AppColors.primary,
                                      ),
                                      onPressed: () {
                                        context.pushReplacement(
                                          AppRoutes.testInstructionScreen,
                                          extra: TestInstructionScreenArgs(
                                            dailyTestModel: test,
                                          ),
                                        );
                                      },
                                    ),
                                    Text("Retest"),
                                  ],
                                ),
                                10.wGap,
                              ]
                              : [],
                    ).padSymmetric(vertical: 6.h),
                  ],
                ),
                10.hGap,
              ],
            );
          }),
        ],
      ).padAll(AppPaddings.appPaddingInt),
    );
  }

  /// Skeleton for loading state
  Padding _buildWhenLoading() {
    return Padding(
      padding: EdgeInsets.all(AppPaddings.appPaddingInt),
      child: Skeletonizer(
        enabled: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('Available Tests', style: AppTexts.heading)],
              ),
              10.hGap,
              TestModule(
                title: "Daily Tests",
                subtitle: "Subject-based Daily Practice",
                prefixIcon: Icons.calendar_today_outlined,
                cards: List.generate(
                  3,
                  (index) => TestTile(
                    title: "Loading Test $index",
                    subtitle: "00 Questions · 0 min",
                    onTap: () {},
                  ).padSymmetric(vertical: 6.h),
                ),
              ),
              10.hGap,
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
                          border: Border.all(
                            color: AppColors.accentColor,
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
                    ],
                    onTap: () {},
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
        ),
      ),
    );
  }
}

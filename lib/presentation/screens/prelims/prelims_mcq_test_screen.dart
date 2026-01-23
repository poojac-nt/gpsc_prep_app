import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/icons/icons.dart';
import 'package:gpsc_prep_app/presentation/blocs/daily_test/daily_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/daily_test/daily_test_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/daily_test/daily_test_state.dart';
import 'package:gpsc_prep_app/presentation/blocs/prelims/prelims_test_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/prelims/prelims_test_state.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_tile.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../blocs/prelims/prelims_test_bloc.dart';

class PrelimsMcqTestScreen extends StatefulWidget {
  const PrelimsMcqTestScreen({super.key});

  @override
  State<PrelimsMcqTestScreen> createState() => _PrelimsMcqTestScreenState();
}

class _PrelimsMcqTestScreenState extends State<PrelimsMcqTestScreen> {
  @override
  void initState() {
    super.initState();
    final currentState = context.read<PrelimsTestBloc>().state;
    if (currentState is! PrelimsTestFetched) {
      context.read<PrelimsTestBloc>().add(FetchPrelimsTest());
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Prelims Tests", style: AppTexts.titleTextStyle),
          centerTitle: false,
        ),
        body: BlocConsumer<PrelimsTestBloc, PrelimsTestState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is PrelimsTestFetching) {
              return _buildWhenLoading();
            } else if (state is PrelimsTestFetched) {
              final tests = state.prelimsTests;
              if (tests.isEmpty) {
                return Center(child: Text("No prelims test available"));
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  return context.read<PrelimsTestBloc>().add(
                    FetchPrelimsTest(),
                  );
                },
                child: ListView.builder(
                  padding: EdgeInsets.all(AppPaddings.appPaddingInt),
                  itemCount: tests.length,
                  itemBuilder: (context, index) {
                    final test = tests[index];
                    final testResult = state.testResults[test.id];
                    final hasResult = testResult != null;

                    // Default values
                    DateTime? submittedAt;
                    bool isEligibleForRetest = false;

                    if (hasResult) {
                      final createdAtString = testResult.createdAt;
                      if (createdAtString != null &&
                          createdAtString.isNotEmpty) {
                        try {
                          submittedAt = DateTime.parse(createdAtString);
                          isEligibleForRetest =
                              DateTime.now().difference(submittedAt).inHours >=
                              12;
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
                          title: "Prelims Tests",
                          subtitle: "Prelims test practice",
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
                                    AppRoutes.mcqTestInstructionScreen,
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
                                                AppIcons.retestIcon,
                                                color: AppColors.primary,
                                              ),
                                              onPressed: () {
                                                context.pushReplacement(
                                                  AppRoutes
                                                      .mcqTestInstructionScreen,
                                                  extra:
                                                      TestInstructionScreenArgs(
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
                  },
                ),
              );
            }
            return Container();
          },
        ),
      ),
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

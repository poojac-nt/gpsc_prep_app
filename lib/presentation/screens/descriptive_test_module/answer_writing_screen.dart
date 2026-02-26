import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/icons/icons.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test/daily_descriptive_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test/daily_descriptive_test_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test/daily_descriptive_test_state.dart';
import 'package:gpsc_prep_app/presentation/screens/prelims/widgets/test_card.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/test_link_generator.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../domain/entities/desc_test_model.dart';
import '../../../domain/entities/test_model.dart';
import '../../widgets/bordered_container.dart';

class AnswerWritingScreen extends StatefulWidget {
  const AnswerWritingScreen({super.key});

  @override
  State<AnswerWritingScreen> createState() => _AnswerWritingScreenState();
}

class _AnswerWritingScreenState extends State<AnswerWritingScreen> {
  @override
  void initState() {
    super.initState();
    final currentState = context.read<DailyDescTestBloc>().state;
    if (currentState is! DailyDescTestFetched) {
      context.read<DailyDescTestBloc>().add(FetchAllTests());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(AppRoutes.studentDashboard);
          },
        ),
        title: Text('Writing Practice', style: AppTexts.titleTextStyle),
      ),
      body: BlocBuilder<DailyDescTestBloc, DailyDescTestState>(
        builder: (context, state) {
          if (state is DailyDescTestFetching) {
            return Center(child: _buildWhenLoading());
          }
          if (state is DailyDescTestFetchFailed) {
            return Center(child: Text(state.failure.toString()));
          }
          if (state is DailyDescTestFetched) {
            final descTests = state.dailyTestModel;
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                return context.read<DailyDescTestBloc>().add(FetchAllTests());
              },
              child: ListView.builder(
                padding: EdgeInsets.all(AppPaddings.appPaddingInt),
                itemCount: descTests.length,
                itemBuilder: (context, index) {
                  final test = descTests[index];
                  final hasAnswer = state.answersMap.containsKey(test.id);
                  return GestureDetector(
                    onTap: () {
                      if (hasAnswer) {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text(
                                  "Answer Already Submitted",
                                  style: AppTexts.titleTextStyle,
                                ),
                                content: Text(
                                  "If you submit again, your previous answer will be overwritten.",
                                  style: AppTexts.subTitle,
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IntrinsicWidth(
                                        child: ActionButton(
                                          text: "Cancel",
                                          onTap: () {
                                            context.pop(); // close dialog
                                          },
                                        ),
                                      ),
                                      10.wGap,
                                      IntrinsicWidth(
                                        child: ActionButton(
                                          text: "Submit Again",
                                          onTap: () {
                                            context.pop(); // close dialog first
                                            context.push(
                                              AppRoutes
                                                  .descriptiveTestInstructionScreen,
                                              extra:
                                                  DescTestInstructionScreenArgs(
                                                    dailyTestModel: test,
                                                  ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                        );
                      } else {
                        context.push(
                          AppRoutes.descriptiveTestInstructionScreen,
                          extra: DescTestInstructionScreenArgs(
                            dailyTestModel: test,
                          ),
                        );
                      }
                    },
                    child: TestCard(
                      descTestModel: test,
                      showFooter: false,
                      trailing:
                          isAnswerUnlocked(test.createdAt)
                              ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      context.push(
                                        AppRoutes.descAnswerScreen,
                                        extra: test,
                                      );
                                    },
                                    icon: Icon(
                                      AppIcons.descAnsIcon,
                                      size: 25.sp,
                                      color: AppColors.primary,
                                    ),
                                    tooltip: "Answer Module",
                                  ),
                                  Text(
                                    "Answer Module",
                                    style: TextStyle(fontSize: 10.sp),
                                  ),
                                ],
                              )
                              : null,
                    ).padSymmetric(vertical: 6.h),
                  );
                },
              ),
              // 10.hGap,
              // TestModule(
              //   title: 'My Submissions',
              //   subtitle: 'Track your Submitted Answers',
              //   prefixIcon: Icons.file_upload_outlined,
              //   cards: [
              //     ActionButton(text: 'View All Submissions', onTap: () {}),
              //     5.hGap,
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Column(
              //           children: [
              //             Text('5 Pending Reviews'),
              //             Text('12 Reviewed'),
              //           ],
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
            );
          }
          return Container();
        },
      ),
    );
  }

  Padding _buildWhenLoading() {
    return Padding(
      padding: EdgeInsets.all(AppPaddings.appPaddingInt),
      child: Skeletonizer(
        enabled: true, // Set this to false when actual data is loaded
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Available Tests', style: AppTexts.heading),
                  IntrinsicWidth(
                    child: ActionButton(text: 'Generate Test', onTap: () {}),
                  ),
                ],
              ),
              10.hGap,

              /// Daily Tests Section
              ...List.generate(
                3,
                (index) => Column(
                  children: [
                    TestCard(
                      descTestModel: DescTestModel(
                        id: 0,
                        name: "Loading Test",
                        totalMarks: 0,
                        noQuestions: 0,
                        createdAt: DateTime.now().toIso8601String(),
                      ),
                      showFooter: false,
                    ),
                    10.hGap,
                  ],
                ),
              ),

              /// Mock Tests Section
              TestCard(
                testModel: TestModel(
                  id: 0,
                  name: "GPSC Mock Test",
                  duration: 0,
                  noQuestions: 0,
                  testType: TestType.mcq,
                  totalMarks: 0,
                ),
                showFooter: false,
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
        ),
      ),
    );
  }

  bool isAnswerUnlocked(String createdAtString) {
    try {
      final createdAtUtc = DateTime.parse(createdAtString).toUtc();
      final unlockTimeUtc = DateTime.utc(
        createdAtUtc.year,
        createdAtUtc.month,
        createdAtUtc.day,
        11,
        30,
      );

      final nowUtc = DateTime.now().toUtc();

      return nowUtc.isAfter(unlockTimeUtc);
    } catch (e) {
      getIt<LogHelper>().e("Error parsing createdAt: $e");
      getIt<SnackBarHelper>().showError("Error parsing createdAt: $e");
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test/daily_descriptive_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test/daily_descriptive_test_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test/daily_descriptive_test_state.dart';
import 'package:gpsc_prep_app/presentation/screens/descriptive_test_module/widgets/answer_writing_card.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/test_link_generator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/cache_manager.dart';
import '../../../domain/entities/desc_test_model.dart';
import '../../../domain/entities/test_model.dart';
import '../../../utils/enums/user_role.dart';
import '../prelims/widgets/test_card.dart';

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
            final role = getIt<CacheManager>().getUserRole();
            if (role == UserRole.admin) {
              context.go(AppRoutes.adminDashboard);
            } else if (role == UserRole.mentor) {
              context.go(AppRoutes.mentorDashboard);
            } else {
              context.go(AppRoutes.studentDashboard);
            }
          },
        ),
        title: Text('Writing Practice', style: AppTexts.titleTextStyle),
      ),
      body: BlocBuilder<DailyDescTestBloc, DailyDescTestState>(
        builder: (context, state) {
          if (state is DailyDescTestFetching) {
            return _buildWhenLoading();
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
                  return AnswerWritingCard(
                    descTestModel: test,
                    isUnlocked: isAnswerUnlocked(test.createdAt),
                    isAttempted: hasAnswer,
                    onStartTestTap:
                        hasAnswer
                            ? () {}
                            : () {
                              context.push(
                                AppRoutes.descriptiveTestInstructionScreen,
                                extra: DescTestInstructionScreenArgs(
                                  dailyTestModel: test,
                                ),
                              );
                            },
                    onAnswerModuleTap: () {
                      context.push(AppRoutes.descAnswerScreen, extra: test);
                    },
                    onShareTap: () async {
                      final url = DeepLinkGenerator.generateShareableUrl(
                        testId: test.id,
                        testType: TestType.desc,
                      );
                      await SharePlus.instance.share(
                        ShareParams(
                          text: "Check out this ${test.name} Test! 🚀\n$url",
                          subject: 'GPSC Prep Test Share',
                        ),
                      );
                    },
                  ).padSymmetric(vertical: 8.h);
                },
              ),
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

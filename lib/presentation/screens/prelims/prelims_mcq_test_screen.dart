import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/data/repositories/prelims_progress_repository.dart';
import 'package:gpsc_prep_app/presentation/blocs/prelims/prelims_test_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/prelims/prelims_test_state.dart';
import 'package:gpsc_prep_app/presentation/screens/prelims/widgets/prelims_test_card.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Prelims Tests", style: AppTexts.titleTextStyle),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          context.read<PrelimsTestBloc>().add(FetchPrelimsTest());
        },
        child: BlocConsumer<PrelimsTestBloc, PrelimsTestState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is PrelimsTestFetching) {
              return _buildWhenLoading();
            } else if (state is PrelimsTestFetched) {
              final tests = state.prelimsTests;
              if (tests.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: 0.7.sh,
                      child: const Center(
                        child: Text("No prelims test available"),
                      ),
                    ),
                  ],
                );
              }
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppPaddings.appPaddingInt),
                itemCount: tests.length,
                itemBuilder: (context, index) {
                  final test = tests[index];
                  final testResult = state.testResults[test.id];
                  final hasResult = testResult != null;

                  // Default values
                  String? lastAttemptedDate;
                  // Check for saved progress
                  final progressRepo = getIt<PrelimsProgressRepository>();
                  final userId = getIt<CacheManager>().getUserId();
                  final savedProgress = progressRepo.getProgress(
                    userId,
                    test.id,
                  );
                  final hasProgress =
                      savedProgress != null && !savedProgress.isExpired();

                  if (hasResult) {
                    final createdAtString = testResult.createdAt;
                    if (createdAtString != null && createdAtString.isNotEmpty) {
                      try {
                        final submittedAt = DateTime.parse(createdAtString);

                        // Simple formatting: dd/MM/yyyy HH:mm
                        final date =
                            "${submittedAt.day.toString().padLeft(2, '0')}/${submittedAt.month.toString().padLeft(2, '0')}/${submittedAt.year}";
                        lastAttemptedDate = date;
                      } catch (e) {
                        // ignore parse error
                      }
                    }
                  }

                  return GestureDetector(
                    onTap:
                        hasResult
                            ? () {}
                            : () {
                              context.push(
                                AppRoutes.prelimsInstructionsScreen,
                                extra: PrelimsInstructionScreenArgs(
                                  testModal: test,
                                  hasProgress: hasProgress,
                                ),
                              );
                            },
                    child: PrelimsTestCard(
                      testModel: test,
                      isAttempted: hasResult,
                      lastAttemptedDate: lastAttemptedDate,
                      hasProgress: hasProgress,
                    ),
                  );
                },
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  /// Skeleton for loading state
  Widget _buildWhenLoading() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppPaddings.appPaddingInt),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: TestModule(
              showShareButton: true,
              title: "General Studies Test ${index + 1}",
              fontSize: 20.sp,
              cards: [
                Row(
                  children: [
                    Icon(
                      Icons.quiz_rounded,
                      size: 14.sp,
                      color: AppColors.gray500,
                    ),
                    4.wGap,
                    Text(
                      "50 Questions",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray500,
                      ),
                    ),
                    16.wGap,
                    Icon(
                      Icons.access_time_filled,
                      size: 14.sp,
                      color: AppColors.gray500,
                    ),
                    4.wGap,
                    Text(
                      "60 min",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
                12.hGap,
                // Add dummy content to increase height
                Text(
                  "This is a sample description to increase the height of the skeleton container.",
                  maxLines: 2,
                  style: TextStyle(fontSize: 14.sp, color: Colors.transparent),
                ),
                12.hGap,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 80.w,
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

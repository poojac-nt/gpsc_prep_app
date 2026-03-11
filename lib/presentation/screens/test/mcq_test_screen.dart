import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/daily_test/daily_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/prelims/widgets/test_card.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/test_link_generator.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../utils/enums/user_role.dart';

class MCQTestScreen extends StatefulWidget {
  const MCQTestScreen({super.key});

  @override
  State<MCQTestScreen> createState() => _MCQTestScreenState();
}

class _MCQTestScreenState extends State<MCQTestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<DailyTestBloc>().state;
      if (state is! DailyTestFetched) {
        context.read<DailyTestBloc>().add(FetchTests());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, value) {
        if (didPop) return;
        final role = getIt<CacheManager>().getUserRole();
        if (role == UserRole.admin) {
          context.go(AppRoutes.adminDashboard);
        } else if (role == UserRole.mentor) {
          context.go(AppRoutes.mentorDashboard);
        } else {
          context.go(AppRoutes.studentDashboard);
        }
      },
      child: DefaultTabController(
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
              ),
              indicatorSize: TabBarIndicatorSize.label,
              labelPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
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
      ),
    );
  }

  /// Build filtered list for each tab
  Widget _buildFilteredList(
    List<TestModel> tests,
    String? filter,
    DailyTestFetched state,
  ) {
    final List<TestModel> filtered =
        filter == null
            ? List<TestModel>.from(tests)
            : tests
                .where(
                  (t) => t.name.toLowerCase().contains(filter.toLowerCase()),
                )
                .toList();

    // Sort: descending available_at, then descending created_at
    filtered.sort((TestModel a, TestModel b) {
      final aAvail = a.availableAt ?? DateTime(0);
      final bAvail = b.availableAt ?? DateTime(0);
      final availCompare = bAvail.compareTo(aAvail);
      if (availCompare != 0) return availCompare;

      final aCreated = a.createdAt ?? DateTime(0);
      final bCreated = b.createdAt ?? DateTime(0);
      return bCreated.compareTo(aCreated);
    });

    if (filtered.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          return context.read<DailyTestBloc>().add(FetchTests());
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!state.hasReachedMax &&
                !state.isFetchingMore &&
                scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 200) {
              context.read<DailyTestBloc>().add(LoadMoreTests());
            }
            return true;
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: 0.8.sh,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No tests available for ${filter ?? "All Subjects"}",
                      ),
                      if (!state.hasReachedMax && state.isFetchingMore) ...[
                        10.hGap,
                        const CircularProgressIndicator(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        return context.read<DailyTestBloc>().add(FetchTests());
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!state.hasReachedMax &&
              !state.isFetchingMore &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
            context.read<DailyTestBloc>().add(LoadMoreTests());
          }
          return true;
        },
        child: ListView.builder(
          padding: EdgeInsets.all(AppPaddings.appPaddingInt),
          itemCount: filtered.length + (state.isFetchingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == filtered.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            final test = filtered[index];
            final testAttemptState = state.testResults[test.id];
            final hasAttempted =
                testAttemptState != null && testAttemptState.attemptsDone > 0;
            final canShowRetestButton =
                testAttemptState != null &&
                testAttemptState.attemptsDone == 1 &&
                testAttemptState.canRetry;
            final submittedAt =
                formatDate(testAttemptState?.lastAttemptAt) ?? 'N/A';
            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (!hasAttempted) {
                      context.push(
                        AppRoutes.mcqTestInstructionScreen,
                        extra: TestInstructionScreenArgs(testModal: test),
                      );
                    }
                  },
                  child: TestCard(
                    testModel: test,
                    isEligibleForRetest: canShowRetestButton,
                    isAttempted: hasAttempted,
                    lastAttemptedDate: submittedAt,
                  ),
                ),
                10.hGap,
              ],
            );
          },
        ),
      ),
    );
  }

  String? formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;

    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (_) {
      return null;
    }
  }

  /// Skeleton for loading state
  Widget _buildWhenLoading() {
    return Padding(
      padding: EdgeInsets.all(AppPaddings.appPaddingInt),
      child: Skeletonizer(
        enabled: true,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              10.hGap,
              TestCard(
                testModel: TestModel(
                  id: 1,
                  name: "name",
                  duration: 120,
                  noQuestions: 3,
                  testType: TestType.mcq,
                  totalMarks: 20,
                ),
                isEligibleForRetest: true,
                isAttempted: false,
                lastAttemptedDate: 'submittedAt',
              ),
              10.hGap,
              TestCard(
                testModel: TestModel(
                  id: 1,
                  name: "name",
                  duration: 120,
                  noQuestions: 3,
                  testType: TestType.mcq,
                  totalMarks: 20,
                ),
                isEligibleForRetest: true,
                isAttempted: false,
                lastAttemptedDate: 'submittedAt',
              ),
              10.hGap,
              TestCard(
                testModel: TestModel(
                  id: 1,
                  name: "name",
                  duration: 120,
                  noQuestions: 3,
                  testType: TestType.mcq,
                  totalMarks: 20,
                ),
                isEligibleForRetest: true,
                isAttempted: false,
                lastAttemptedDate: 'submittedAt',
              ),
              10.hGap,
              TestCard(
                testModel: TestModel(
                  id: 1,
                  name: "name",
                  duration: 120,
                  noQuestions: 3,
                  testType: TestType.mcq,
                  totalMarks: 20,
                ),
                isEligibleForRetest: true,
                isAttempted: false,
                lastAttemptedDate: 'submittedAt',
              ),
              10.hGap,
              TestCard(
                testModel: TestModel(
                  id: 1,
                  name: "name",
                  duration: 120,
                  noQuestions: 3,
                  testType: TestType.mcq,
                  totalMarks: 20,
                ),
                isEligibleForRetest: true,
                isAttempted: false,
                lastAttemptedDate: 'submittedAt',
              ),
              10.hGap,
              TestCard(
                testModel: TestModel(
                  id: 1,
                  name: "name",
                  duration: 120,
                  noQuestions: 3,
                  testType: TestType.mcq,
                  totalMarks: 20,
                ),
                isEligibleForRetest: true,
                isAttempted: false,
                lastAttemptedDate: 'submittedAt',
              ),
            ],
          ).padAll(AppPaddings.appPaddingInt),
        ),
      ),
    );
  }
}

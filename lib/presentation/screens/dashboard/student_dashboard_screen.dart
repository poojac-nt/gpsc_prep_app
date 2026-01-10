import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/config/environment.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/detailed_test_result_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/authentication/auth_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/connectivity_bloc/connectivity_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/dashboard_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/widgets/goal_reminder.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/widgets/icon_container.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/widgets/last_snapshot_card.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/widgets/performance_card.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:hive/hive.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../blocs/dashboard/dashboard_bloc_event.dart';
import '../../blocs/dashboard/dashboard_bloc_state.dart';
import '../../widgets/connectivity_handler_dialog.dart';
import '../../widgets/custom_painter.dart';
import '../dashboard/widgets/selection_drawer.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final currentState = context.read<DashboardBloc>().state;
    if (currentState is! DashboardAnalyticsFetched) {
      context.read<DashboardBloc>().add(FetchDashboardAnalytics());
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = getIt<CacheManager>().user;
    return Scaffold(
      drawer: SelectionDrawer(),
      drawerEdgeDragWidth: 150,
      appBar: AppBar(
        title: Text(
          'Dashboard ${Environment.isDevelopment ? '(Dev)' : ''}',
          style: AppTexts.titleTextStyle,
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          /// ✅ Handle connectivity changes
          BlocListener<ConnectivityBloc, ConnectivityState>(
            listenWhen: (previous, current) => previous != current,
            listener: (context, state) {
              if (state is ConnectivityOffline) {
                ConnectivityDialogHelper.showOfflineDialog(context);
              } else if (state is ConnectivityOnline) {
                syncLatestIfExists(context);
                syncOfflineQuestionResults();
                ConnectivityDialogHelper.dismissDialog(context);
              }
            },
          ),

          /// ✅ Handle authentication state
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) => current is Unauthenticated,
            listener: (context, state) {
              context.go(AppRoutes.login);
            },
          ),
        ],
        child: BlocBuilder<DashboardBloc, DashboardBlocState>(
          builder: (context, state) {
            if (state is FetchingDashboardAnalytics) {
              return _buildWhenLoading(context);
            }
            if (state is DashboardAnalyticsFetchedFailed) {
              return Center(child: Text(state.failure.message));
            }
            if (state is DashboardAnalyticsFetched) {
              return _buildDashboardContent(context, state, user?.name ?? '');
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// ✅ Dashboard content when data is ready
  Widget _buildDashboardContent(
    BuildContext context,
    DashboardAnalyticsFetched state,
    String username,
  ) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        return context.read<DashboardBloc>().add(FetchDashboardAnalytics());
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GoalReminderCard(),
            15.hGap,
            PerformanceCard(
              completedTest: state.dashboardAnalytics.testsAttempted,
              totalTest: state.dashboardAnalytics.totalTestsAvailable,
              accuracy: state.dashboardAnalytics.userAllOverAccuracy,
            ),
            10.hGap,

            ///Daily test
            Row(
              children: [
                Expanded(
                  child: StartTestCard(
                    title: 'Daily Test',
                    subTitle: 'MCQ Tests',
                    color: AppColors.primary,
                    onTap: () => context.push(AppRoutes.mcqTestScreen),
                  ),
                ),
                20.wGap,
                Expanded(
                  child: StartTestCard(
                    color: Color(0xff6366F2),
                    title: "Daily Test",
                    subTitle: "Written Tests",
                    buttonTextColor: Color(0xff6366F2),
                    buttonBgColor: Colors.white,
                    onTap: () => context.push(AppRoutes.answerWriting),
                  ),
                ),
              ],
            ),
            10.hGap,
            LastSnapshotCard(
              testName:
                  state.dashboardAnalytics.lastTest.testName ??
                  'No test attempted',
              totalMarks: state.dashboardAnalytics.lastTest.score?.toInt() ?? 0,
              obtainedMarks:
                  state.dashboardAnalytics.lastTest.gainedScore?.toInt() ?? 0,
            ),
          ],
        ).padAll(20),
      ),
    );
  }

  /// ✅ Skeleton while loading
  Skeletonizer _buildWhenLoading(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      ignoreContainers: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal Reminder Card
            Container(
              height: 180.h,
              padding: EdgeInsets.all(AppPaddings.dashboardContainerPadding),
              decoration: BoxDecoration(
                borderRadius: AppBorders.dashboardBorderRadius,
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 120.w, height: 14.h),
                  10.hGap,
                  SizedBox(width: 180.w, height: 22.h),
                  10.hGap,
                  SizedBox(width: 220.w, height: 14.h),
                  20.hGap,
                  Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      borderRadius: AppBorders.dashboardBorderRadius,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            15.hGap,

            // Performance Card
            Container(
              padding: EdgeInsets.all(AppPaddings.dashboardContainerPadding),
              decoration: BoxDecoration(
                borderRadius: AppBorders.dashboardBorderRadius,
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                  ),
                  20.wGap,
                  Expanded(
                    child: Container(
                      height: 120.h,
                      decoration: BoxDecoration(
                        borderRadius: AppBorders.dashboardBorderRadius,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            15.hGap,

            // Two Test Cards Skeleton
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 170.h,
                    decoration: BoxDecoration(
                      borderRadius: AppBorders.dashboardBorderRadius,
                      color: Colors.white,
                    ),
                  ),
                ),
                10.wGap,
                Expanded(
                  child: Container(
                    height: 170.h,
                    decoration: BoxDecoration(
                      borderRadius: AppBorders.dashboardBorderRadius,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            15.hGap,

            // Last Snapshot Skeleton
            Container(
              padding: EdgeInsets.all(AppPaddings.dashboardContainerPadding),
              decoration: BoxDecoration(
                borderRadius: AppBorders.dashboardBorderRadius,
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Container(height: 20.h),
                  15.hGap,
                  Container(height: 10.h),
                  15.hGap,
                  Container(height: 50.h),
                ],
              ),
            ),

            15.hGap,

            // Test List Skeleton
            Container(
              height: 100.h,
              decoration: BoxDecoration(
                borderRadius: AppBorders.dashboardBorderRadius,
                color: Colors.white,
              ),
            ),
            15.hGap,
            Container(
              height: 100.h,
              decoration: BoxDecoration(
                borderRadius: AppBorders.dashboardBorderRadius,
                color: Colors.white,
              ),
            ),
          ],
        ).padAll(AppPaddings.defaultPadding),
      ),
    );
  }

  /// ✅ Sync offline results if internet is available
  Future<void> syncLatestIfExists(BuildContext context) async {
    final testResultBox = getIt<Box<TestResultModel>>();
    final latest = testResultBox.get('latest');
    if (latest == null) return;

    final log = getIt<LogHelper>();
    final isOnline =
        context.read<ConnectivityBloc>().state is ConnectivityOnline;

    if (isOnline) {
      try {
        await getIt<SupabaseHelper>().insertDailyMcqTestsResults(latest);
        await testResultBox.delete('latest');
        if (!context.mounted) return;
        context.read<DashboardBloc>().add(FetchDashboardAnalytics());
        log.i('✅ Synced test result to Supabase and removed from Hive');
      } catch (e) {
        log.e('❌ Sync failed: $e');
      }
    }
  }

  Future<void> syncOfflineQuestionResults() async {
    final box = Hive.box<DetailedTestResult>('detailed_test_results');
    final log = getIt<LogHelper>();
    final isOnline = getIt<ConnectivityBloc>().state is ConnectivityOnline;

    if (!isOnline) {
      log.e('❌ Cannot sync question results — No Internet');
      return;
    }

    if (box.isEmpty) {
      log.i('ℹ️ No offline question results to sync');
      return;
    }

    final repository = getIt<TestRepository>();
    final keysToDelete = <dynamic>[];

    for (var key in box.keys) {
      final result = box.get(key);
      if (result == null) continue;

      final response = await repository.insertTestResultDetail(
        detailedTestResult: result,
      );

      response.fold(
        (failure) => log.e(
          '❌ Failed to sync questionId ${result.questionId}: ${failure.message}',
        ),
        (_) {
          log.i('✅ Synced questionId ${result.questionId}');
          keysToDelete.add(key);
        },
      );
    }

    if (keysToDelete.isNotEmpty) {
      await box.deleteAll(keysToDelete);
      log.i(
        '🧹 Deleted ${keysToDelete.length} synced offline results from Hive',
      );
    }
  }
}

class StartTestCard extends StatelessWidget {
  final Color color;
  final String buttonText;
  final String title;
  final String subTitle;
  final Color buttonTextColor;
  final Color buttonBgColor;
  final VoidCallback onTap;

  const StartTestCard({
    super.key,
    required this.color,
    this.buttonText = 'Start Test',
    required this.title,
    required this.subTitle,
    this.buttonTextColor = Colors.white,
    this.buttonBgColor = Colors.blue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppBorders.dashboardBorderRadius,
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: AppBorders.dashboardBorderRadius,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  8.hGap,
                  IconContainer(
                    borderRadius: BorderRadius.circular(100.r),
                    icon: Icons.menu_book,
                    color: color,
                  ),
                  10.hGap,
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  5.hGap,
                  Text(
                    subTitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  5.hGap,
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBgColor,
                      foregroundColor: buttonTextColor,
                    ),
                    child: Row(
                      children: [
                        Text(buttonText),
                        Expanded(child: Icon(Icons.navigate_next)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -10,
              right: -10,
              child: SizedBox(
                width: 120.w,
                height: 120.w,
                child: CustomPaint(painter: CirclePainter(color: color)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

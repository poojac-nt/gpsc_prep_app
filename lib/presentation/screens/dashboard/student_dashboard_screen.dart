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
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:hive/hive.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../blocs/dashboard/dashboard_bloc_event.dart';
import '../../blocs/dashboard/dashboard_bloc_state.dart';
import '../../widgets/connectivity_handler_dialog.dart';
import '../../widgets/elevated_container.dart';
import '../dashboard/widgets/selection_drawer.dart';
import '../dashboard/widgets/stats_widget.dart';
import '../dashboard/widgets/test_container.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(FetchAttemptedTests());
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
                syncLatestIfExists();
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
            if (state is FetchingAttemptedTests) {
              return _buildWhenLoading(context);
            }
            if (state is AttemptedTestsFetchedFailed) {
              return Center(child: Text(state.failure.message));
            }
            if (state is AttemptedTestsFetched) {
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
    AttemptedTestsFetched state,
    String username,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppBorders.borderRadius,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(20.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, $username',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  5.hGap,
                  Text(
                    'Ready to ace your GPSC exam? Let\'s continue your preparation.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ),
          15.hGap,
          Row(
            children: [
              Expanded(
                child: ElevatedContainer(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 15.h,
                  ),
                  child: StatsWidget(
                    text: 'Test taken',
                    num: state.totalTests.toString(),
                    icon: Icons.radar,
                    iconColor: Colors.green,
                  ),
                ),
              ),
              10.wGap,
              Expanded(
                child: ElevatedContainer(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 15.h,
                  ),
                  child: StatsWidget(
                    text: 'Avg Score',
                    num: "${state.avgScore.toStringAsFixed(2)} %",
                    icon: Icons.score_outlined,
                    iconColor: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          10.hGap,
          Text(
            'Daily MCQ Tests',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          10.hGap,
          ElevatedContainer(
            child: TestContainer(
              title: "Daily Test",
              description: "Take today's practice test",
              iconColor: Colors.blue,
              icon: Icons.menu_book,
              buttonTitle: 'Start Test',
              onTap: () => context.push(AppRoutes.mcqTestScreen),
            ),
          ),
          10.hGap,
          Text(
            'Answer Writing Practice',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          10.hGap,
          ElevatedContainer(
            child: TestContainer(
              title: "Daily Writing Practice",
              description:
                  "Practice descriptive answers and improve overall performance",
              iconColor: Colors.purple,
              icon: Icons.menu_book,
              buttonTitle: 'Start Writing',
              onTap: () => context.push(AppRoutes.answerWriting),
            ),
          ),
        ],
      ).padAll(AppPaddings.defaultPadding),
    );
  }

  /// ✅ Skeleton while loading
  Skeletonizer _buildWhenLoading(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppBorders.borderRadius,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ...',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    5.hGap,
                    Text(
                      'Ready to ace your GPSC exam? Let\'s continue your preparation.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            15.hGap,
            // skeleton stats + test container
          ],
        ).padAll(AppPaddings.defaultPadding),
      ),
    );
  }

  /// ✅ Sync offline results if internet is available
  Future<void> syncLatestIfExists() async {
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
        context.read<DashboardBloc>().add(FetchAttemptedTests());
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

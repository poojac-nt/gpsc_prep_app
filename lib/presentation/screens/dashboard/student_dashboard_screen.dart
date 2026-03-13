import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/config/environment.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/detailed_test_result_model.dart';
import 'package:gpsc_prep_app/domain/entities/leaderboard_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/authentication/auth_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/connectivity_bloc/connectivity_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/dashboard/dashboard_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/widgets/dashboard_container.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/widgets/goal_reminder.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/widgets/icon_container.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/widgets/last_snapshot_card.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/widgets/performance_card.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:hive/hive.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../utils/enums/user_role.dart';
import '../../widgets/connectivity_handler_dialog.dart';
import '../../widgets/custom_painter.dart';
import '../dashboard/widgets/selection_drawer.dart';
import 'widgets/paid_course_card.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final PageController _pageController = PageController();
  int _leaderboardIndex = 0;

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xffCB8C08); // Gold
      case 2:
        return const Color(0xff9E9E9E); // Silver
      case 3:
        return const Color(0xffCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

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
      drawer:
          getIt<CacheManager>().getUserRole() == UserRole.admin
              ? null
              : SelectionDrawer(),
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
                syncOfflineResults(context);
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
            GoalReminderCard(
              activeDays: state.dashboardAnalytics.activeDaysLast7,
            ),
            15.hGap,
            PerformanceCard(
              completedTest: state.dashboardAnalytics.testsAttempted,
              totalTest: state.dashboardAnalytics.totalTestsAvailable,
              accuracy: state.dashboardAnalytics.userAllOverAccuracy,
            ),
            15.hGap,
            const PaidCourseCard(),
            15.hGap,

            ///Daily test
            Text(
              "Daily Practice".toUpperCase(),
              style: TextStyle(
                color: AppColors.gray500,
                fontWeight: FontWeight.bold,
              ),
            ),
            10.hGap,
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
                    buttonTextColor: Colors.white,
                    buttonBgColor: Color(0xff6366F2),
                    onTap: () => context.push(AppRoutes.answerWriting),
                  ),
                ),
              ],
            ),
            10.hGap,
            LastSnapshotCard(lastTest: state.dashboardAnalytics.lastTest),
            10.hGap,
            state.leaderboardData.isNotEmpty
                ? _buildLeaderboardCarousel(state.leaderboardData)
                : SizedBox.shrink(),
          ],
        ).padAll(20),
      ),
    );
  }

  Widget _buildLeaderboardCarousel(List<LeaderboardModel> allLeaders) {
    final prelimsLeaders =
        allLeaders
            .where((l) => l.testType.toLowerCase().contains('prelim'))
            .toList();
    final mainsLeaders =
        allLeaders
            .where((l) => l.testType.toLowerCase().contains('main'))
            .toList();

    final pages = <Widget>[
      leaderboardSection("Prelims Leaderboard", prelimsLeaders),
      leaderboardSection("Mains Leaderboard", mainsLeaders),
    ];

    return Column(
      children: [
        SizedBox(
          height: 280.h,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _leaderboardIndex = index;
              });
            },
            children: pages,
          ),
        ),
        10.hGap,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              height: 8.h,
              width: _leaderboardIndex == index ? 24.w : 8.w,
              decoration: BoxDecoration(
                color:
                    _leaderboardIndex == index
                        ? AppColors.primary
                        : AppColors.gray200,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  DashboardContainer leaderboardSection(
    String title,
    List<LeaderboardModel> leaders,
  ) {
    return DashboardContainer(
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                color: Colors.yellowAccent.shade700,
                size: 25.sp,
              ),
              10.wGap,
              Text(title, style: AppTexts.dashboardContainerTitle),
            ],
          ),
          10.hGap,
          const Divider(color: Colors.grey, thickness: 0.7),
          Expanded(
            child:
                leaders.isEmpty
                    ? Center(
                      child: Text(
                        "No rankings available yet",
                        style: AppTexts.dashboardSmallTexts.copyWith(
                          color: AppColors.gray400,
                        ),
                      ),
                    )
                    : ListView.builder(
                      itemCount: leaders.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final profilePicture = leaders[index].profilePicture;
                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            tileColor:
                                index == 0
                                    ? const Color(0xffCB8C08).withAlpha(15)
                                    : null,
                            shape:
                                index == 0
                                    ? RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(60.r),
                                    )
                                    : null,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                            ),
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "#${leaders[index].rank}",
                                  style: TextStyle(
                                    color: _getRankColor(leaders[index].rank),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                10.wGap,
                                CircleAvatar(
                                  backgroundColor:
                                      profilePicture == null
                                          ? Colors.blueAccent.withAlpha(40)
                                          : Colors.transparent,
                                  backgroundImage:
                                      profilePicture != null
                                          ? NetworkImage(profilePicture)
                                          : null,
                                  child:
                                      profilePicture == null
                                          ? Icon(
                                            Icons.person,
                                            color: Colors.grey.shade600,
                                            size: 20.sp,
                                          )
                                          : null,
                                ),
                              ],
                            ),
                            title: Text(
                              leaders[index].studentName,
                              style: AppTexts.dashboardMediumTitle.copyWith(
                                fontSize: 15.sp,
                              ),
                            ),
                            subtitle: Text(
                              '${leaders[index].totalMarks} marks',
                              style: AppTexts.dashboardSmallTexts,
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
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
            DashboardContainer(
              height: 180.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 120.w, height: 14.h),
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
            DashboardContainer(
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
                  child: DashboardContainer(
                    height: 170.h,
                    child: SizedBox.shrink(),
                  ),
                ),
                10.wGap,
                Expanded(
                  child: DashboardContainer(
                    height: 170.h,
                    child: SizedBox.shrink(),
                  ),
                ),
              ],
            ),

            15.hGap,

            // Last Snapshot Skeleton
            DashboardContainer(
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
  Future<void> syncOfflineResults(BuildContext context) async {
    final log = getIt<LogHelper>();
    final isOnline =
        context.read<ConnectivityBloc>().state is ConnectivityOnline;

    if (!isOnline) return;

    final testResultBox = getIt<Box<TestResultModel>>();
    final detailedBox = Hive.box<DetailedTestResult>('detailed_test_results');

    final latest = testResultBox.get('latest');
    final offlineDetails = <DetailedTestResult>[];
    final detailKeys = <dynamic>[];

    if (latest == null && detailedBox.isEmpty) {
      log.i('ℹ️ No offline results to sync');
      return;
    }

    // Collect all offline detailed results
    for (final key in detailedBox.keys) {
      final result = detailedBox.get(key);
      if (result != null) {
        offlineDetails.add(result);
        detailKeys.add(key);
      }
    }

    if (latest != null) {
      try {
        final repository = getIt<TestRepository>();
        final response = await repository.submitTestResultWithDetails(
          latest,
          offlineDetails,
        );

        response.fold(
          (failure) {
            log.e('❌ Sync failed: ${failure.message}');
          },
          (_) async {
            await testResultBox.delete('latest');
            await detailedBox.deleteAll(detailKeys);
            if (!context.mounted) return;
            context.read<DashboardBloc>().add(FetchDashboardAnalytics());
            log.i('✅ Synced offline test result and details to Supabase');
          },
        );
      } catch (e) {
        log.e('❌ Sync exception: $e');
      }
    } else if (offlineDetails.isNotEmpty) {
      log.w('⚠️ Found detailed results but no summary result to sync.');
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
    this.buttonBgColor = const Color(0xff3b82f6),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardContainer(
      padding: EdgeInsets.zero,
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
                  Text(title, style: AppTexts.dashboardMediumTitle),
                  5.hGap,
                  Text(subTitle, style: AppTexts.dashboardSmallTexts),
                  8.hGap,
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBgColor,
                      foregroundColor: buttonTextColor,
                      padding: EdgeInsets.symmetric(
                        vertical: 8.h,
                        horizontal: 13.w,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            buttonText,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          4.wGap,
                          Icon(Icons.navigate_next, size: 20.sp),
                        ],
                      ),
                    ),
                  ),
                  5.hGap,
                ],
              ),
            ),
            Positioned(
              top: -10.h,
              right: -10.w,
              child: SizedBox(
                width: 120.w,
                height: 120.h,
                child: CustomPaint(painter: CirclePainter(color: color)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

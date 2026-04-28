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
import 'package:gpsc_prep_app/utils/services/fcm_service.dart';
import 'package:hive/hive.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final InAppReview _inAppReview = InAppReview.instance;
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
    // Request notification permission
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<FCMService>().requestNotificationPermission();
    });
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
                : const SizedBox.shrink(),
            15.hGap,
            _buildSocialMediaLinks(),
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
          height: 310.h,
          child: PageView(
            clipBehavior: Clip.none,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withAlpha(38),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: const Color(0xFFD4AF37),
                  size: 20.sp,
                ),
              ),
              12.wGap,
              Text(title, style: AppTexts.dashboardContainerTitle),
            ],
          ),
          12.hGap,
          if (leaders.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(color: AppColors.primary.withAlpha(25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 12.sp,
                    color: AppColors.primary,
                  ),
                  6.wGap,
                  Flexible(
                    child: Text(
                      leaders.first.testName,
                      style: AppTexts.dashboardSmallTexts.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 11.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            12.hGap,
          ],
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
                    : ListView.separated(
                      itemCount: leaders.length,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) => 8.hGap,
                      itemBuilder: (context, index) {
                        final leader = leaders[index];
                        final profilePicture = leader.profilePicture;
                        final isFirst = index == 0;

                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isFirst
                                    ? AppColors.primary.withAlpha(8)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color:
                                  isFirst
                                      ? AppColors.primary.withAlpha(25)
                                      : Colors.grey.shade100,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Rank Badge
                              Text(
                                "#${leader.rank}",
                                style: TextStyle(
                                  color: _getRankColor(leader.rank),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                              12.wGap,
                              // Avatar
                              Container(
                                padding: EdgeInsets.all(1.5.r),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        isFirst
                                            ? AppColors.primary.withAlpha(76)
                                            : Colors.grey.shade200,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 16.r,
                                  backgroundColor:
                                      profilePicture == null
                                          ? AppColors.primary.withAlpha(25)
                                          : Colors.transparent,
                                  backgroundImage:
                                      profilePicture != null
                                          ? NetworkImage(profilePicture)
                                          : null,
                                  child:
                                      profilePicture == null
                                          ? Icon(
                                            Icons.person,
                                            color: AppColors.primary,
                                            size: 16.sp,
                                          )
                                          : null,
                                ),
                              ),
                              12.wGap,
                              // Name
                              Expanded(
                                child: Text(
                                  leader.studentName,
                                  style: AppTexts.dashboardMediumTitle.copyWith(
                                    fontSize: 13.sp,
                                    fontWeight:
                                        isFirst
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Marks
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${leader.totalMarks}',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Text(
                                    'marks',
                                    style: TextStyle(
                                      color: AppColors.gray400,
                                      fontSize: 9.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaLinks() {
    return DashboardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Connect with Us", style: AppTexts.dashboardContainerTitle),
          20.hGap,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _socialIcon(
                imagePath: 'assets/images/telegram_logo.png',
                label: 'Telegram',
                color: const Color(0xff0088cc),
                onTap: () => _launchSocialUrl('https://t.me/starics_prep'),
              ),
              _socialIcon(
                imagePath: 'assets/images/x_logo.png',
                label: 'X',
                color: Colors.black,
                onTap: () => _launchSocialUrl('https://x.com/star_ics89'),
              ),
              _socialIcon(
                imagePath: 'assets/images/gmail_logo.png',
                label: 'Gmail',
                color: const Color(0xffEA4335),
                onTap: () => _launchSocialUrl('mailto:star.ics89@gmail.com'),
              ),
              _socialIcon(
                imagePath: 'assets/images/whatsapp_logo.png',
                label: 'WhatsApp',
                color: const Color(0xff25D366),
                onTap: () => _launchSocialUrl('https://wa.me/+91 6357440321'),
              ),
              _socialIcon(
                icon: Icons.star_rounded,
                label: 'Rate Us',
                color: Colors.amber,
                onTap: () async {
                  try {
                    if (await _inAppReview.isAvailable()) {
                      await _inAppReview.requestReview();
                    }
                    await _inAppReview.openStoreListing(
                      appStoreId: "app.starics",
                    );
                  } catch (e) {
                    getIt<LogHelper>().e('Error requesting review: $e');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchSocialUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      // Launch in external app if available, otherwise fallback to browser
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      getIt<LogHelper>().e('Could not launch social link: $url. Error: $e');
    }
  }

  Widget _socialIcon({
    String? imagePath,
    IconData? icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(40), width: 1),
            ),
            child:
                imagePath != null
                    ? Image.asset(imagePath, width: 26.w, height: 26.w)
                    : Icon(icon, color: color, size: 26.w),
          ),
          8.hGap,
          Text(
            label,
            style: AppTexts.dashboardSmallTexts.copyWith(
              fontSize: 11.sp,
              color: AppColors.gray700,
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

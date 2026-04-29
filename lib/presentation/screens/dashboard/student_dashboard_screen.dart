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
import 'package:gpsc_prep_app/presentation/screens/dashboard/widgets/last_snapshot_card.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/widgets/performance_card.dart';
import 'package:gpsc_prep_app/presentation/widgets/start_test_card_widget.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/fcm_service.dart';
import 'package:hive/hive.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/enums/user_role.dart';
import '../../widgets/connectivity_handler_dialog.dart';
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
      drawer: getIt<CacheManager>().getUserRole() == UserRole.admin
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
    final prelimsLeaders = allLeaders
        .where((l) => l.testType.toLowerCase().contains('prelim'))
        .toList();
    final mainsLeaders = allLeaders
        .where((l) => l.testType.toLowerCase().contains('main'))
        .toList();

    final availableSections = <Map<String, dynamic>>[];
    if (prelimsLeaders.isNotEmpty) {
      availableSections.add({'title': 'Prelims', 'data': prelimsLeaders});
    }
    if (mainsLeaders.isNotEmpty) {
      availableSections.add({'title': 'Mains', 'data': mainsLeaders});
    }

    if (availableSections.isEmpty) return const SizedBox.shrink();

    return DashboardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    color: const Color(0xFFF1C40F),
                    size: 26.sp,
                  ),
                  10.wGap,
                  Text(
                    "Leaderboard",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1C1E),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  context.push(
                    AppRoutes.leaderboardScreen,
                    extra: _leaderboardIndex,
                  );
                },
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "View All",
                      style: TextStyle(
                        color: const Color(0xFF3B82F6),
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: const Color(0xFF3B82F6),
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),
          15.hGap,
          // Custom Tab Selector (if more than 1 category)
          if (availableSections.length > 1)
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4F9),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: List.generate(availableSections.length, (index) {
                  final isSelected = _leaderboardIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _leaderboardIndex = index;
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(15.r),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            "${availableSections[index]['title']}",
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF1A1C1E)
                                  : const Color(0xFF64748B),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          if (availableSections.length > 1) 20.hGap,
          Builder(
            builder: (context) {
              if (availableSections.length == 1) {
                return leaderboardSection(
                  availableSections[0]['title'],
                  availableSections[0]['data'] as List<LeaderboardModel>,
                  showTitle: true,
                );
              }

              final maxItems = availableSections
                  .map((sec) => (sec['data'] as List).length)
                  .fold(0, (max, current) => current > max ? current : max);
              final dynamicHeight = 12.h + (maxItems * 87.h);

              return SizedBox(
                height: dynamicHeight,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _leaderboardIndex = index;
                    });
                  },
                  children: availableSections
                      .map(
                        (sec) => leaderboardSection(
                          sec['title'],
                          sec['data'] as List<LeaderboardModel>,
                          showTitle: false,
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget leaderboardSection(
    String title,
    List<LeaderboardModel> leaders, {
    bool showTitle = true,
  }) {
    if (leaders.isEmpty) return const SizedBox.shrink();
    final testName = leaders.first.testName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category and Test Name Headers
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTitle)
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3B82F6),
                  letterSpacing: 1.2,
                ),
              ),
            if (showTitle) 4.hGap,
            Text(
              testName,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1C1E),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF1F4F9)),
        ...List.generate(leaders.length, (index) {
          final leader = leaders[index];
          final isFirst = index == 0;
          final isLast = index == leaders.length - 1;
          final userItSelf = getIt<CacheManager>().getUserId() == leader.userId;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Row(
                  children: [
                    // Rank
                    SizedBox(
                      width: 25.w,
                      child: Text(
                        "${leader.rank}",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: isFirst
                              ? const Color(0xFFF1C40F)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    10.wGap,
                    // Avatar with badge for #1
                    Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isFirst
                                  ? const Color(0xFFF1C40F)
                                  : const Color(0xFFE2E8F0),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 24.r,
                            backgroundColor: const Color(0xFFF1F4F9),
                            backgroundImage: leader.profilePicture != null
                                ? NetworkImage(leader.profilePicture!)
                                : null,
                            child: leader.profilePicture == null
                                ? Icon(
                                    Icons.person,
                                    color: const Color(0xFF94A3B8),
                                    size: 24.sp,
                                  )
                                : null,
                          ),
                        ),
                        if (isFirst)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4.r),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1C40F),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.star_rounded,
                                color: Colors.white,
                                size: 12.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                    15.wGap,
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            leader.studentName + (userItSelf ? " (You)" : ""),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1C1E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          4.hGap,
                          Text(
                            "Score: ${leader.totalMarks.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF1F4F9),
                ),
            ],
          );
        }),
      ],
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
            child: imagePath != null
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

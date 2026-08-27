import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/domain/entities/leaderboard_screen_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/leaderboard/leaderboard_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/leaderboard/leaderboard_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/leaderboard/leaderboard_state.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class LeaderboardScreen extends StatefulWidget {
  final int initialIndex;

  const LeaderboardScreen({super.key, this.initialIndex = 0});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LeaderboardBloc _leaderboardBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _leaderboardBloc = getIt<LeaderboardBloc>()..add(FetchLeaderboardData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: AppTexts.titleTextStyle.copyWith(fontSize: 22.sp),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.h),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
              tabs: const [
                Tab(text: 'Prelims'),
                Tab(text: 'Mains'),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        bloc: _leaderboardBloc,
        builder: (context, state) {
          if (state is LeaderboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LeaderboardError) {
            return Center(child: Text(state.failure.message));
          } else if (state is LeaderboardLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildTestList('Prelims', state.leaderboardData.prelims),
                _buildTestList('Mains', state.leaderboardData.mains),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTestList(String type, List<Main> toppers) {
    // Group by testId
    final Map<int, List<Main>> groupedToppers = {};
    for (var topper in toppers) {
      if (!groupedToppers.containsKey(topper.testId)) {
        groupedToppers[topper.testId] = [];
      }
      groupedToppers[topper.testId]!.add(topper);
    }

    final testIds = groupedToppers.keys.toList();

    if (testIds.isEmpty) {
      return Center(
        child: Text(
          'No leaderboard data available',
          style: AppTexts.dashboardSmallTexts,
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: testIds.length,
      itemBuilder: (context, index) {
        final testId = testIds[index];
        final testToppers = groupedToppers[testId]!;
        // Sort by rank
        testToppers.sort((a, b) => a.rank.compareTo(b.rank));
        return _buildTestCard(testToppers, type);
      },
    );
  }

  Widget _buildTestCard(List<Main> testToppers, String type) {
    if (testToppers.isEmpty) return const SizedBox.shrink();
    final firstTopper = testToppers.first;
    final isSingle = testToppers.length == 1;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            firstTopper.testName,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1C1E),
            ),
            textAlign: TextAlign.center,
          ),
          20.hGap,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rank 2
              if (!isSingle)
                Expanded(
                  child: testToppers.length > 1
                      ? _buildScorer(testToppers[1], 2, type, isMulti: true)
                      : const SizedBox.shrink(),
                ),

              // Rank 1
              Expanded(
                child: _buildScorer(
                  testToppers[0],
                  1,
                  type,
                  isMulti: !isSingle,
                ),
              ),

              // Rank 3
              if (!isSingle)
                Expanded(
                  child: testToppers.length > 2
                      ? _buildScorer(testToppers[2], 3, type, isMulti: true)
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScorer(
    Main scorer,
    int rank,
    String type, {
    bool isMulti = false,
  }) {
    final userItSelf = scorer.userId == getIt<CacheManager>().getUserId();
    final double avatarSize = rank == 1 ? 55.r : 45.r;
    final Color rankColor = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
        ? const Color(0xFFC0C0C0)
        : const Color(0xFFCD7F32);

    final String scoreDisplay = type == 'Prelims'
        ? '${scorer.score?.toStringAsFixed(2) ?? 0}'
        : '${scorer.totalMarks?.toStringAsFixed(2) ?? 0}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.all(rank == 1 ? 3.r : 2.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: rankColor, width: 2),
              ),
              child: ClipOval(
                child:
                    scorer.profilePicture != null &&
                        scorer.profilePicture!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: scorer.profilePicture!,
                        width: avatarSize,
                        height: avatarSize,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade100,
                          child: Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: avatarSize * 0.5,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade100,
                          child: Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: avatarSize * 0.5,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade100,
                        width: avatarSize,
                        height: avatarSize,
                        child: Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: avatarSize * 0.5,
                        ),
                      ),
              ),
            ),
            Positioned(
              bottom: -8.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: rankColor,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    color: rank == 1 ? Colors.black87 : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
        20.hGap,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            userItSelf ? '${scorer.fullName}(Me)' : scorer.fullName,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: isMulti ? 11.sp : 14.sp,
              color: const Color(0xFF1A1C1E),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        2.hGap,
        Text(
          scoreDisplay,
          style: TextStyle(
            color: const Color(0xFF3B82F6),
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

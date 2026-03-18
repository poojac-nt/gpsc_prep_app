import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_dashbord_data.dart';
import 'package:gpsc_prep_app/domain/entities/mentor_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/mentor_dashboard/mentor_dashboard_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/dialogs/logout_dialog.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:intl/intl.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/router/args.dart';

import '../../blocs/edit_mentor/edit_mentor_bloc.dart';

class MentorDashboardScreen extends StatefulWidget {
  const MentorDashboardScreen({super.key});

  @override
  State<MentorDashboardScreen> createState() => _MentorDashboardScreenState();
}

class _MentorDashboardScreenState extends State<MentorDashboardScreen> {
  bool _isProfileLoading = false;
  MentorModel? mentorModel;

  @override
  void initState() {
    super.initState();
    context.read<MentorDashboardBloc>().add(FetchMentorDashboardData());
    context.read<EditMentorBloc>().add(LoadInitialProfile());
  }

  Future<void> _onProfileTap() async {
    if (mentorModel != null) {
      context.push(
        AppRoutes.editMentor,
        extra: EditMentorScreenArgs(mentor: mentorModel!),
      );
    } else {
      final userId = getIt<CacheManager>().getUserId();
      context.read<EditMentorBloc>().add(FetchMentorByUserId(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditMentorBloc, EditMentorState>(
      listener: (context, state) {
        if (state is MentorDetailLoading) {
          setState(() => _isProfileLoading = true);
        } else {
          setState(() => _isProfileLoading = false);
        }
        if (state is MentorOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load mentor profile: ${state.message}'),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldColor,
        appBar: _buildAppBar(),
        body: BlocBuilder<MentorDashboardBloc, MentorDashboardState>(
          builder: (context, state) {
            if (state is MentorDashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MentorDashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: TextStyle(color: Colors.red, fontSize: 14.sp),
                    ),
                    16.hGap,
                    ElevatedButton(
                      onPressed:
                          () => context.read<MentorDashboardBloc>().add(
                            FetchMentorDashboardData(),
                          ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is MentorDashboardLoaded) {
              final data = state.data;
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  context.read<MentorDashboardBloc>().add(
                    FetchMentorDashboardData(),
                  );
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      24.hGap,
                      _buildStatCards(data),
                      16.hGap,
                      _buildAllFreeTestsCard(context),
                      16.hGap,
                      _buildLatestAssignedHeader(),
                      16.hGap,
                      _buildTestList(data.latestAssignments),
                      40.hGap,
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.scaffoldColor,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 20.w,
      title: Row(
        children: [
          _buildProfileAvatar(),
          12.wGap,
          Text(
            'Mentor Dashboard',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.gray900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => showLogoutDialog(context),
          icon: Icon(Icons.logout, size: 24.sp, color: Colors.red),
        ),
        12.wGap,
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return BlocBuilder<EditMentorBloc, EditMentorState>(
      builder: (context, state) {
        String? profilePic;
        String name = "";

        if (state is MentorDetailLoaded) {
          mentorModel = state.mentor;
          profilePic = state.mentor.user.profilePicture;
          name = state.mentor.user.name;
        } else if (state is MentorUpdateSuccess) {
          mentorModel = state.mentor;
          profilePic = state.mentor.user.profilePicture;
          name = state.mentor.user.name;
        } else if (mentorModel != null) {
          profilePic = mentorModel!.user.profilePicture;
          name = mentorModel!.user.name;
        }

        return GestureDetector(
          onTap: _isProfileLoading ? null : _onProfileTap,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8.h),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: AppColors.gray200,
                  backgroundImage:
                      profilePic != null && profilePic.isNotEmpty
                          ? NetworkImage(profilePic)
                          : null,
                  child:
                      (profilePic == null || profilePic.isEmpty)
                          ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : "M",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                          : null,
                ),
                if (_isProfileLoading)
                  SizedBox(
                    height: 36.r,
                    width: 36.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCards(MentorDashboardData data) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Total\nAssigned',
              value: data.totalAssigned.toString(),
              icon: Icons.assignment_ind_rounded,
              color: AppColors.primary,
            ),
          ),
          16.wGap,
          Expanded(
            child: _buildStatCard(
              title: 'Completed\nTests',
              value: data.totalCompleted.toString(),
              icon: Icons.analytics_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Icon(icon, color: AppColors.gray400, size: 20.sp)],
          ),
          12.hGap,
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.gray500,
              height: 1.2,
            ),
          ),
          12.hGap,
          Text(
            value,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.gray900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllFreeTestsCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.freeTestReview),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_rounded,
                color: AppColors.primary,
                size: 24.sp,
              ),
            ),
            16.wGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Free Tests',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                  4.hGap,
                  Text(
                    'View and review the complete list of free tests',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            8.wGap,
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestAssignedHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Latest Assigned Tests',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.gray900,
            ),
          ),
          TextButton(
            onPressed: () => context.push(AppRoutes.allAssignedTests),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              children: [
                Text(
                  'All Tests',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                4.wGap,
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestList(List<LatestAssignment> assignments) {
    if (assignments.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(32.r),
        child: Center(
          child: Text(
            'No tests assigned yet.',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.gray500,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return GestureDetector(
          onTap:
              () => context.push(
                AppRoutes.testStudentsList,
                extra: {
                  'testId': assignment.testId,
                  'testName': assignment.testName,
                },
              ),
          child: _buildTestCard(assignment),
        );
      },
    );
  }

  Widget _buildTestCard(LatestAssignment assignment) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.testName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                4.hGap,
                Text(
                  'Assigned: ${DateFormat('MMM dd, yyyy').format(assignment.latestAssignedAt)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '${assignment.totalStudentsSubmissions} Submissions',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.gray700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

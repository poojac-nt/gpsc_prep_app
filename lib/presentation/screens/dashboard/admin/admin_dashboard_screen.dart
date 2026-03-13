import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/presentation/blocs/admin/admin_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/dialogs/logout_dialog.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    context.read<AdminBloc>().add(FetchAdminStats());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            context.read<AdminBloc>().add(FetchAdminStats());
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                10.hGap,
                BlocBuilder<AdminBloc, AdminState>(
                  builder: (context, state) {
                    String totalMentors = '0';
                    String totalCourses = '0';

                    if (state is AdminStatsLoaded) {
                      totalMentors = state.stats.totalMentors.toString();
                      totalCourses = state.stats.totalCourses.toString();
                    }

                    return _buildPlatformOverview(
                      totalMentors: totalMentors,
                      totalCourses: totalCourses,
                      isLoading: state is AdminStatsLoading,
                    );
                  },
                ),
                20.hGap,
                _buildCoreManagement(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Admin Console',
          textAlign: TextAlign.center,
          style: AppTexts.titleTextStyle.copyWith(
            fontSize: 22.sp,
            color: const Color(0xff1f2937),
          ),
        ),
        40.wGap,
        IconButton(
          onPressed: () => showLogoutDialog(context),
          icon: Icon(Icons.logout, size: 24.sp, color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildPlatformOverview({
    required String totalMentors,
    required String totalCourses,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                title: 'Total Mentors',
                value: totalMentors,
                icon: Icons.people_outline,
                iconBgColor: const Color(0xfff5f3ff),
                iconColor: const Color(0xff8b5cf6),
                isLoading: isLoading,
              ),
            ),
            16.wGap,
            Expanded(
              child: _buildOverviewCard(
                title: 'Live Course',
                value: totalCourses,
                icon: Icons.library_books_outlined,
                iconBgColor: const Color(0xfff0fdfa),
                iconColor: const Color(0xff06b6d4),
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    bool isLoading = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
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
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: iconColor, size: 20.sp),
              ),
              if (isLoading)
                SizedBox(
                  width: 12.w,
                  height: 12.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  ),
                ),
            ],
          ),
          16.hGap,
          Text(
            title,
            style: AppTexts.subTitle.copyWith(
              color: const Color(0xff6b7280),
              fontSize: 13.sp,
            ),
          ),
          4.hGap,
          Text(
            value,
            style: AppTexts.heading.copyWith(
              fontSize: 24.sp,
              color: const Color(0xff111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoreManagement(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Core Management',
          style: AppTexts.heading.copyWith(
            fontSize: 20.sp,
            color: const Color(0xff111827),
          ),
        ),
        16.hGap,
        _buildManagementItem(
          context,
          title: 'Manage Mentors',
          subtitle: 'View and manage all mentors',
          icon: Icons.people_outline_rounded,
          iconBgColor: const Color(0xffeff6ff),
          iconColor: const Color(0xff3b82f6),
          onTap: () => context.push(AppRoutes.mentorList),
        ),
        12.hGap,
        _buildManagementItem(
          context,
          title: 'Assignment Queue',
          subtitle: 'Assign Pending Reviews',
          icon: Icons.assignment_outlined,
          iconBgColor: const Color(0xfffff7ed),
          iconColor: const Color(0xfff97316),
          onTap: () => context.push(AppRoutes.mentorAssign),
        ),
        12.hGap,
        _buildManagementItem(
          context,
          title: 'Add New Course',
          subtitle: 'Create a new course offering',
          icon: Icons.add_business_outlined,
          iconBgColor: const Color(0xfff0f9ff),
          iconColor: const Color(0xff0284c7),
          onTap: () => context.push(AppRoutes.addCourse),
        ),
        12.hGap,
        _buildManagementItem(
          context,
          title: 'Test Library',
          subtitle: 'Upload and configure exams',
          icon: Icons.library_add_outlined,
          iconBgColor: const Color(0xfffff1f2),
          iconColor: const Color(0xfff43f5e),
          onTap: () => context.push(AppRoutes.addQuestionScreen),
        ),
        12.hGap,
        _buildManagementItem(
          context,
          title: 'Study Resources',
          subtitle: 'Upload New Resources ',
          icon: Icons.menu_book_outlined,
          iconBgColor: const Color(0xfff0fdfa),
          iconColor: const Color(0xff0d9488),
          onTap: () => context.push(AppRoutes.uploadStudyMaterial),
        ),
        12.hGap,
        _buildManagementItem(
          context,
          title: 'All Tests',
          subtitle: 'View and share all tests',
          icon: Icons.assignment_turned_in_outlined,
          iconBgColor: const Color(0xfff5f3ff),
          iconColor: const Color(0xff8b5cf6),
          onTap: () => context.push(AppRoutes.allTests),
        ),
      ],
    );
  }

  Widget _buildManagementItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
    Color? subtitleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24.sp),
            ),
            16.wGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTexts.title.copyWith(
                      fontSize: 16.sp,
                      color: const Color(0xff111827),
                    ),
                  ),
                  4.hGap,
                  Text(
                    subtitle,
                    style: AppTexts.subTitle.copyWith(
                      fontSize: 12.sp,
                      color: subtitleColor ?? const Color(0xff9ca3af),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xffd1d5db),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }
}

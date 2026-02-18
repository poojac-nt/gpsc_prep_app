import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/presentation/blocs/authentication/auth_bloc.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/enums/user_role.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class SelectionDrawer extends StatelessWidget {
  SelectionDrawer({super.key});

  static final CacheManager cache = getIt<CacheManager>();

  final user = cache.user;
  final isStudent = cache.getUserRole() == UserRole.student;
  final isMentor = cache.getUserRole() == UserRole.mentor;
  final isAdmin = cache.getUserRole() == UserRole.admin;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                child: Column(
                  children: [
                    if (isStudent) ...[
                      _buildMenuItem(
                        context,
                        icon: Icons.content_paste_rounded,
                        title: 'MCQ Tests',
                        onTap: () => context.push(AppRoutes.mcqTestScreen),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.assignment_outlined,
                        title: 'Prelims',
                        onTap:
                            () => context.push(AppRoutes.prelimsMcqTestScreen),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.description,
                        title: 'Descriptive Tests',
                        onTap: () => context.push(AppRoutes.answerWriting),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.analytics_outlined,
                        title: 'Analytics',
                        onTap: () => context.push(AppRoutes.analyticsScreen),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.person,
                        title: 'Profile',
                        onTap: () => context.push(AppRoutes.profile),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.file_download_outlined,
                        title: 'Study Material',
                        onTap: () => context.push(AppRoutes.languageSelection),
                      ),
                    ],
                    if (!isStudent) ...[
                      _buildMenuItem(
                        context,
                        icon: Icons.file_upload_outlined,
                        title: 'Upload Test',
                        onTap: () => context.push(AppRoutes.addQuestionScreen),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.library_add_outlined,
                        title: 'Add Course',
                        onTap: () => context.push(AppRoutes.addCourse),
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.file_upload_outlined,
                        title: 'Upload Study Material',
                        onTap:
                            () => context.push(AppRoutes.uploadStudyMaterial),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    iconColor: Colors.redAccent,
                    textColor: Colors.redAccent,
                    onTap: () => showLogoutDialog(context),
                    isLogout: true,
                  ),
                  10.hGap,
                  Text(
                    "Version: ${getIt<CacheManager>().getAppVersion()}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            width: 50.r,
            height: 50.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withAlpha(20),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(10),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child:
                  user?.profilePicture != null &&
                          user!.profilePicture!.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: user!.profilePicture!,
                        fit: BoxFit.cover,
                        errorWidget:
                            (context, url, error) =>
                                Icon(Icons.error, color: AppColors.primary),
                      )
                      : Container(
                        color: Colors.grey.shade50,
                        child: Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 28.sp,
                        ),
                      ),
            ),
          ),
          16.wGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'User',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                4.hGap,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(10),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    "UPSC Aspirant",
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    bool isLogout = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: isLogout ? Colors.redAccent.withAlpha(5) : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isLogout) Navigator.pop(context);
            onTap();
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? AppColors.primary.withAlpha(80),
                  size: 22.sp,
                ),
                16.wGap,
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isLogout)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14.sp,
                    color: Colors.grey.shade300,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withAlpha(10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    size: 32.sp,
                    color: Colors.redAccent,
                  ),
                ),
                16.hGap,
                Text(
                  "Log Out",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                8.hGap,
                Text(
                  "Are you sure you want to log out of your account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                24.hGap,
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    12.wGap,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<AuthBloc>().add(LogOutRequested());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          "Log Out",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

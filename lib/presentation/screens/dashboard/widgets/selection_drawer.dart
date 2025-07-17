import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/auth_bloc.dart';
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
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 40.r,
                    height: 40.r,
                    child: ClipOval(
                      child:
                          user?.profilePicture != null &&
                                  user!.profilePicture!.isNotEmpty
                              ? CachedNetworkImage(
                                imageUrl: user!.profilePicture!,
                                fit: BoxFit.cover,
                                errorWidget:
                                    (context, url, error) => Icon(
                                      Icons.error,
                                      color: AppColors.primary,
                                    ),
                              )
                              : Container(
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                ),
                              ),
                    ),
                  ),
                  10.wGap,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user!.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      3.hGap,
                      Text("UPSC aspirant"),
                    ],
                  ),
                ],
              ),
              5.hGap,
              Divider(
                thickness: 1,
                indent: 0,
                endIndent: 0,
                color: Colors.grey,
              ),
              isStudent
                  ? commonWidget(
                    () {
                      context.pop();
                      context.go(AppRoutes.dashboard);
                    },
                    Icons.dashboard,
                    'Dashboard',
                  )
                  : SizedBox.shrink(),
              isStudent
                  ? commonWidget(
                    () {
                      context.pop();
                      context.push(AppRoutes.mcqTestScreen);
                    },
                    Icons.content_paste_rounded,
                    'MCQ Tests',
                  )
                  : SizedBox.shrink(),
              // commonWidget(
              //   () => context.push(AppRoutes.answerWriting),
              //   Icons.edit_document,
              //   'Answer Writing',
              // ),
              isStudent
                  ? commonWidget(
                    () {
                      context.pop();
                      context.push(AppRoutes.profile);
                    },
                    Icons.person,
                    'Profile',
                  )
                  : SizedBox.shrink(),
              commonWidget(
                () {
                  context.pop();
                  context.push(AppRoutes.addQuestionScreen);
                },
                Icons.file_upload_outlined,
                'Upload Test',
              ),
              commonWidget(
                () => showLogoutDialog(context),
                Icons.logout,
                iconColor: Colors.red,
                'Logout',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget commonWidget(
    VoidCallback onTap,
    IconData icon,
    String title, {
    Color iconColor = Colors.black,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            5.wGap,
            Text(title, style: TextStyle(fontSize: 16.sp)),
          ],
        ),
      ),
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // prevent accidental dismiss
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 12,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon
                  Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.logout,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    "Logout",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Message
                  Text(
                    "Are you sure you want to logout?",
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.read<AuthBloc>().add(LogOutRequested());
                            context.pushReplacement(AppRoutes.login);
                          },
                          child: const Text("Logout"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

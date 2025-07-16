import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/auth_bloc.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class SelectionDrawer extends StatelessWidget {
  SelectionDrawer({super.key});

  final user = getIt<CacheManager>().user;

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
                  CircleAvatar(
                    backgroundImage:
                        user?.profilePicture != null &&
                                user!.profilePicture!.isNotEmpty
                            ? NetworkImage(user!.profilePicture!)
                            : null,
                    radius: 20.r,
                    child:
                        (user?.profilePicture == null ||
                                user!.profilePicture!.isEmpty)
                            ? Icon(
                              Icons.person,
                              color: AppColors.primary,
                            ) // fallback icon or asset
                            : null,
                  ),
                  10.wGap,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'John Deo',
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
              commonWidget(
                () => context.push(AppRoutes.home),
                Icons.dashboard,
                'Dashboard',
              ),
              commonWidget(
                () => context.push(AppRoutes.mcqTestScreen),
                Icons.content_paste_rounded,
                'MCQ Tests',
              ),
              // commonWidget(
              //   () => context.push(AppRoutes.answerWriting),
              //   Icons.edit_document,
              //   'Answer Writing',
              // ),
              commonWidget(
                () => context.push(AppRoutes.profile),
                Icons.person,
                'Profile',
              ),
              commonWidget(
                () => context.push(AppRoutes.addQuestionScreen),
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

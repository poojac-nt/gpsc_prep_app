import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';
import 'package:gpsc_prep_app/presentation/screens/profile/edit_profile_bloc.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class SelectionDrawer extends StatefulWidget {
  const SelectionDrawer({super.key});

  @override
  State<SelectionDrawer> createState() => _SelectionDrawerState();
}

class _SelectionDrawerState extends State<SelectionDrawer> {
  UserModel? user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<EditProfileBloc>().add(LoadInitialProfile());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditProfileBloc, EditProfileState>(
      listener: (context, state) {
        if (state is EditProfileLoaded) {
          setState(() {
            user = state.user;
          });
        }
      },
      child: Drawer(
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
                  'MCQ Tets',
                ),
                commonWidget(
                  () => context.push(AppRoutes.answerWriting),
                  Icons.edit_document,
                  'Answer Writing',
                ),
                commonWidget(
                  () => context.push(AppRoutes.profile),
                  Icons.person,
                  'Profile',
                ),
                commonWidget(
                  () => context.push(AppRoutes.home),
                  Icons.notifications,
                  'Setting',
                ),
                commonWidget(
                  () => context.push(AppRoutes.home),
                  Icons.logout,
                  'Logout',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget commonWidget(VoidCallback onTap, IconData icon, String title) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
        child: Row(
          children: [
            Icon(icon, color: Colors.black),
            5.wGap,
            Text(title, style: TextStyle(fontSize: 16.sp)),
          ],
        ),
      ),
    );
  }
}

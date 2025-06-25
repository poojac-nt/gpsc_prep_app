import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/sizedbox.dart';

class SelectionDrawer extends StatelessWidget {
  SelectionDrawer({super.key});

  final List<String> textList = [
    'Dashboard',
    'MCQ Tests',
    'Answer Writing',
    'Profile',
    'Settings',
    'Logout',
  ];
  final List<IconData> icons = [
    Icons.dashboard,
    Icons.content_paste_rounded,
    Icons.edit_document,
    Icons.person,
    Icons.settings,
    Icons.logout,
  ];
  final List<String> routePaths = [
    AppRoutes.home,
    AppRoutes.testScreen,
    AppRoutes.answerWriting,
    AppRoutes.profile,
    AppRoutes.home,
    AppRoutes.home,
  ];

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
                    backgroundImage: NetworkImage('https://picsum.photos/206'),
                    radius: 20.r,
                  ),
                  10.wGap,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Deo',
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
              ListView.builder(
                shrinkWrap: true,
                itemCount: textList.length,
                itemBuilder:
                    (context, index) => InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push(routePaths[index]);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 15.h,
                          horizontal: 10.w,
                        ),
                        child: Row(
                          children: [
                            Icon(icons[index]),
                            5.wGap,
                            Text(
                              textList[index],
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

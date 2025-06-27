import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/screens/profile/widgets/exam_pref_tile.dart';
import 'package:gpsc_prep_app/presentation/screens/profile/widgets/quick_stats.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import '../../widgets/custom_checkbox.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_tag.dart';
import '../../widgets/custom_text_field.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  List<String> exams = [
    "GPSC Class 1-2",
    "UPSC Prelims",
    "GSSSB Clerk",
    "GPSC AE",
    "TAT",
    "HTAT",
  ];
  List<String> notificationPrefs = [
    "Email Update",
    "Push Notification",
    "Daily Test Reminder",
  ];
  List<String> languages = ["English", "Gujrati", "Hindi"];
  List<bool> values = [true, false, true, true, false, false];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Profile', style: AppTexts.titleTextStyle)),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppPaddings.defaultPadding),
          child: Column(
            children: [
              TestModule(
                title: "Profile Photo",
                cards: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            "https://picsum.photos/206",
                          ),
                          radius: 40.r,
                        ),

                        Text(
                          "John Deo",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "John.deo@example.coooooooooooooom",
                          textAlign: TextAlign.center,
                          style: AppTexts.labelTextStyle.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              10.hGap,
              TestModule(
                title: 'Quick Stats',
                cards: [
                  QuickStats(text: "Test Taken", num: "64"),
                  10.hGap,
                  QuickStats(text: "Average Score", num: "83"),
                  10.hGap,
                  QuickStats(text: "Study Strike", num: "12 days"),
                  10.hGap,
                  QuickStats(text: "Rank", num: "#264"),
                ],
              ),
              10.hGap,
              TestModule(
                title: 'Personal Information',
                icon: Icons.person_outline,
                cards: [
                  10.hGap,
                  Text("Full Name", style: AppTexts.labelTextStyle),
                  5.hGap,
                  CustomTextField(text: "John Doe"),
                  10.hGap,
                  Text("Email", style: AppTexts.labelTextStyle),
                  5.hGap,
                  CustomTextField(text: "john.doe@example.com"),
                  10.hGap,
                  Text("Mobile Number", style: AppTexts.labelTextStyle),
                  5.hGap,
                  CustomTextField(text: "+91 9876543210"),
                  10.hGap,
                  Text("Address", style: AppTexts.labelTextStyle),
                  5.hGap,
                  CustomTextField(
                    text: "123 Main Street, Ahmedabad, Gujarat 380001",
                    maxline: 3,
                  ),
                ],
              ),
              10.hGap,
              TestModule(
                title: "Exam Preferences",
                subtitle: "Select the exams you are preparing for",
                cards: [
                  5.hGap,
                  Text("Preparing for exams", style: AppTexts.labelTextStyle),
                  5.hGap,
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: exams.length,
                    itemBuilder:
                        (context, index) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.h),
                          child: ExamPrefTile(
                            title: exams[index],
                            value: index == 3,
                          ),
                        ),
                  ),
                  10.hGap,
                  Text("Selected Exams", style: AppTexts.labelTextStyle),
                  5.hGap,
                  Wrap(
                    runSpacing: 3,
                    spacing: 5,
                    children: [
                      CustomTag(exam: exams[0]),
                      CustomTag(exam: exams[1]),
                    ],
                  ),
                ],
              ),
              10.hGap,
              TestModule(
                title: "App Preferences",
                subtitle: "Customize your app experience",
                cards: [
                  5.hGap,
                  Text("Preferred Language", style: AppTexts.labelTextStyle),
                  10.hGap,
                  CustomDropdown(items: languages, hintText: "Choose Language"),
                  10.hGap,
                  Text(
                    "Notification Preferences",
                    style: AppTexts.labelTextStyle,
                  ),
                  5.hGap,
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder:
                        (context, index) => CustomCheckbox(
                          title: notificationPrefs[index],
                          value: values[index],
                        ),
                  ),
                ],
              ),
              10.hGap,
              TestModule(
                title: "Account Actions",
                cards: [
                  8.hGap,
                  BorderedContainer(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 7.h,
                    ),
                    child: Center(
                      child: Text(
                        "Change Password",
                        style: AppTexts.labelTextStyle,
                      ),
                    ),
                  ),
                  8.hGap,
                  BorderedContainer(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 7.h,
                    ),
                    child: Center(
                      child: Text(
                        "Download My Data",
                        style: AppTexts.labelTextStyle,
                      ),
                    ),
                  ),
                  8.hGap,
                  BorderedContainer(
                    borderColor: Colors.red,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 7.h,
                    ),
                    child: Center(
                      child: Text(
                        "Delete Account",
                        style: AppTexts.labelTextStyle.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

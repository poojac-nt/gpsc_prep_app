import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/sizedbox.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile', style: AppTexts.titleTextStyle),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.edit))],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppPaddings.defaultPadding,
          child: Column(
            children: [
              BorderedContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Profile Photo",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    10.hGap,
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
                            "John.deo@example.cooooooooooooooom",
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
              ),
              10.hGap,
              BorderedContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quick Stats",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    10.hGap,
                    QuickStats(text: "Test Taken", num: "64"),
                    10.hGap,
                    QuickStats(text: "Average Score", num: "83"),
                    10.hGap,
                    QuickStats(text: "Study Strike", num: "12 days"),
                    10.hGap,
                    QuickStats(text: "Rank", num: "#264"),
                  ],
                ),
              ),
              10.hGap,
              BorderedContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_2_outlined),
                        8.wGap,
                        Text(
                          "Personal Information",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    20.hGap,
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
              ),
              10.hGap,
              BorderedContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Exam Preferences",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    5.hGap,
                    Text(
                      "Select the exams you are preparing for",
                      style: AppTexts.subTitle,
                    ),
                    20.hGap,
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
              ),
              10.hGap,
              BorderedContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "App Preferences",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    5.hGap,
                    Text(
                      "Customize your app experience",
                      style: AppTexts.subTitle,
                    ),
                    20.hGap,
                    Text("Preferred Language", style: AppTexts.labelTextStyle),
                    10.hGap,
                    DropdownMenu(
                      width: double.infinity,
                      inputDecorationTheme: InputDecorationTheme(
                        border: OutlineInputBorder(
                          borderRadius: AppBorders.borderRadius,
                        ),
                        isDense: true,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                      ),
                      hintText: "Choose Language",
                      dropdownMenuEntries: [
                        DropdownMenuEntry(value: "English", label: "English"),
                        DropdownMenuEntry(value: "Hindi", label: "Hindi"),
                        DropdownMenuEntry(value: "Gujrati", label: "Gujrati"),
                      ],
                      menuStyle: MenuStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.white),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                    ),
                    10.hGap,
                    Text(
                      "Notification Preferences",
                      style: AppTexts.labelTextStyle,
                    ),
                    5.hGap,
                    Row(
                      children: [
                        Checkbox(
                          value: true,
                          onChanged: (value) {},
                          fillColor: WidgetStateProperty.resolveWith((state) {
                            if (state.contains(WidgetState.selected)) {
                              return Colors.black;
                            }
                            return Colors.white;
                          }),
                          checkColor: Colors.white,
                        ),
                        Text(
                          "Push Notifications",
                          style: AppTexts.labelTextStyle.copyWith(
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: false,
                          onChanged: (value) {},
                          fillColor: WidgetStateProperty.resolveWith((state) {
                            if (state.contains(WidgetState.selected)) {
                              return Colors.black;
                            }
                            return Colors.white;
                          }),
                          checkColor: Colors.white,
                        ),
                        Text(
                          "Email Updates",
                          style: AppTexts.labelTextStyle.copyWith(
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: false,
                          onChanged: (value) {},
                          fillColor: WidgetStateProperty.resolveWith((state) {
                            if (state.contains(WidgetState.selected)) {
                              return Colors.black;
                            }
                            return Colors.white;
                          }),
                          checkColor: Colors.white,
                        ),
                        Text(
                          "Daily Test Reminder",
                          style: AppTexts.labelTextStyle.copyWith(
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              10.hGap,
              BorderedContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account Actions",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    8.hGap,
                    BorderedContainer(
                      padding: EdgeInsets.symmetric(
                        horizontal: 83.w,
                        vertical: 8.h,
                      ),
                      child: Text(
                        "Change Password",
                        style: AppTexts.labelTextStyle,
                      ),
                    ),
                    8.hGap,
                    BorderedContainer(
                      padding: EdgeInsets.symmetric(
                        horizontal: 80.w,
                        vertical: 8.h,
                      ),
                      child: Text(
                        "Download My Data",
                        style: AppTexts.labelTextStyle,
                      ),
                    ),
                    8.hGap,
                    BorderedContainer(
                      padding: EdgeInsets.symmetric(
                        horizontal: 91.w,
                        vertical: 8.h,
                      ),
                      child: Text(
                        "Delete Account",
                        style: AppTexts.labelTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTag extends StatelessWidget {
  const CustomTag({super.key, required this.exam});

  final String exam;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 5.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: Colors.black),
        ),
        child: Text(
          exam,
          style: TextStyle(
            color: Colors.black,
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class ExamPrefTile extends StatelessWidget {
  const ExamPrefTile({super.key, required this.title, this.value = false});
  final String title;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return BorderedContainer(
      padding: EdgeInsets.zero,
      radius: BorderRadius.zero,
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (value) {},
            fillColor: WidgetStateProperty.resolveWith((state) {
              if (state.contains(WidgetState.selected)) {
                return Colors.black;
              }
              return Colors.white;
            }),
            checkColor: Colors.white,
          ),
          Text(title, style: AppTexts.labelTextStyle.copyWith(fontSize: 13.sp)),
        ],
      ),
    );
  }
}

class QuickStats extends StatelessWidget {
  const QuickStats({super.key, required this.text, required this.num});
  final String text;
  final String num;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text, style: AppTexts.subTitle.copyWith(fontSize: 14.sp)),
        Text(
          num,
          style: AppTexts.subTitle.copyWith(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

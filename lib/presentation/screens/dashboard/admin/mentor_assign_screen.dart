import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class MentorAssignScreen extends StatefulWidget {
  const MentorAssignScreen({super.key});

  @override
  State<MentorAssignScreen> createState() => _MentorAssignScreenState();
}

class _MentorAssignScreenState extends State<MentorAssignScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildPendingHeader(), _buildTestList()],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.scaffoldColor,
      elevation: 0,
      centerTitle: true,
      title: Text(
        "Tests with Submissions",
        style: TextStyle(
          color: AppColors.gray900,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.gray900,
          size: 20.sp,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildPendingHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Pending Submissions",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              "4 New",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestList() {
    final List<Map<String, dynamic>> dummyData = [
      {
        "title": "Advanced Physics...",
        "subtitle": "Science • 24 submissions",
        "icon": Icons.science_outlined,
        "iconBg": AppColors.primary.withAlpha(20),
        "iconColor": AppColors.primary,
        "action": "Assign",
      },
      {
        "title": "Calculus II Final",
        "subtitle": "Mathematics • 12 submissions",
        "icon": Icons.calculate_outlined,
        "iconBg": AppColors.orange500.withAlpha(20),
        "iconColor": AppColors.orange500,
        "action": "Assign",
      },
      {
        "title": "World History Unit 4",
        "subtitle": "Humanities • 8 submissions",
        "icon": Icons.public_outlined,
        "iconBg": AppColors.green500.withAlpha(20),
        "iconColor": AppColors.green500,
        "action": "Assign",
      },
      {
        "title": "Data Structures Quiz",
        "subtitle": "CS • 15 submissions",
        "icon": Icons.code_rounded,
        "iconBg": Colors.purple.withAlpha(20),
        "iconColor": Colors.purple,
        "action": "Assign",
      },
      {
        "title": "Literature Analysis",
        "subtitle": "English • All assigned",
        "icon": Icons.edit_note_rounded,
        "iconBg": AppColors.gray200,
        "iconColor": AppColors.gray700,
        "action": "View",
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: dummyData.length,
      itemBuilder: (context, index) {
        final item = dummyData[index];
        return _buildTestSubmissionCard(item);
      },
    );
  }

  Widget _buildTestSubmissionCard(Map<String, dynamic> item) {
    bool isView = item["action"] == "View";
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: item["iconBg"],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(item["icon"], color: item["iconColor"], size: 24.sp),
          ),
          16.wGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["title"],
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                2.hGap,
                Text(
                  item["subtitle"],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (item["action"] == "Assign") {
                GoRouter.of(
                  context,
                ).push(AppRoutes.assignMentorDetail, extra: item["title"]);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isView ? AppColors.gray100 : AppColors.primary,
              foregroundColor: isView ? AppColors.gray700 : Colors.white,
              elevation: 0,
              minimumSize: Size(80.w, 36.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: Text(
              item["action"],
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/domain/entities/overall_analytics_model.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class AllSubjectsAnalyticsScreen extends StatefulWidget {
  final List<SubjectScore> subjectsData;

  const AllSubjectsAnalyticsScreen({required this.subjectsData, super.key});

  @override
  State<AllSubjectsAnalyticsScreen> createState() =>
      _AllSubjectsAnalyticsScreenState();
}

class _AllSubjectsAnalyticsScreenState
    extends State<AllSubjectsAnalyticsScreen> {
  String sortBy = "Name";
  late List<SubjectScore> sortedSubjects;

  @override
  void initState() {
    super.initState();
    _sortSubjects();
  }

  void _sortSubjects() {
    sortedSubjects = List.from(widget.subjectsData);
    if (sortBy == "Name") {
      sortedSubjects.sort((a, b) => a.subjectName.compareTo(b.subjectName));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text("SUBJECT PERFORMANCE", style: AppTexts.titleTextStyle),
      ),
      body: Column(
        children: [
          _buildSortHeader(),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: sortedSubjects.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _buildSubjectCard(sortedSubjects[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Sort:",
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          8.wGap,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: DropdownButton<String>(
              value: sortBy,
              underline: SizedBox(),
              alignment: AlignmentDirectional.bottomStart,
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 18.sp,
                color: AppColors.primary,
              ),
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              borderRadius: BorderRadius.circular(6.r),
              dropdownColor: Colors.white,
              items: const [
                DropdownMenuItem(value: "Name", child: Text("Name")),
                DropdownMenuItem(value: "Accuracy", child: Text("Accuracy")),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    sortBy = newValue;
                    _sortSubjects();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(SubjectScore data) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.subjectName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                4.hGap,
                Text(
                  "${data.attemptedTests} Tests Attempted",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${data.accuracyPercentage.toInt()}%",
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              2.hGap,
              Text(
                "ACCURACY",
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/domain/entities/overall_analytics_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/detailed_analytics/detailed_analytics_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/analytics_date_range_picker.dart';
import 'package:gpsc_prep_app/presentation/widgets/empty_state_ui.dart';
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
  DateTimeRange? _selectedDateRange;
  String _sortBy = "Name";

  @override
  void initState() {
    super.initState();
    // Default to last 7 days including today
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 7)),
      end: now,
    );
  }

  List<SubjectScore> _getSortedData(List<SubjectScore> data) {
    final List<SubjectScore> sorted = List.from(data);
    if (_sortBy == "Name") {
      sorted.sort((a, b) => a.subjectName.compareTo(b.subjectName));
    } else if (_sortBy == "Accuracy") {
      sorted.sort(
        (a, b) => b.accuracyPercentage.compareTo(a.accuracyPercentage),
      );
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailedAnalyticsBloc, DetailedAnalyticsState>(
      builder: (context, state) {
        final data = state.subjectData;
        final isLoading = state.isLoading;

        return Scaffold(
          backgroundColor: AppColors.analyticsBg,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Subject Analysis",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body:
              isLoading && data.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        16.hGap,
                        AnalyticsDateRangePicker(
                          selectedRange: _selectedDateRange,
                          onRangeSelected: (picked) {
                            setState(() {
                              _selectedDateRange = picked;
                            });
                            context.read<DetailedAnalyticsBloc>().add(
                              LoadDetailedSubjectEvent(
                                from: picked.start,
                                to: picked.end,
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: _buildSortHeader(),
                        ),
                        if (data.isEmpty && !isLoading)
                          EmptyStateUi()
                        else ...[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Text(
                              "SUBJECT PERFORMANCE",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gray500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          16.hGap,
                          _buildSubjectsBreakdown(data),
                        ],
                        40.hGap,
                      ],
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildSortHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Sort by:",
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.gray500,
              fontWeight: FontWeight.w500,
            ),
          ),
          8.wGap,
          DropdownButton<String>(
            dropdownColor: Colors.white,
            value: _sortBy,
            underline: SizedBox(),
            icon: Icon(
              Icons.sort_rounded,
              size: 18.sp,
              color: AppColors.primary,
            ),
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            items: const [
              DropdownMenuItem(value: "Name", child: Text("Name")),
              DropdownMenuItem(value: "Accuracy", child: Text("Accuracy")),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _sortBy = newValue;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsBreakdown(List<SubjectScore> data) {
    final sortedData = _getSortedData(data);
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: sortedData.length,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      separatorBuilder: (context, index) => 16.hGap,
      itemBuilder: (context, index) {
        final item = sortedData[index];
        return _buildSubjectCard(item);
      },
    );
  }

  Widget _buildSubjectCard(SubjectScore data) {
    final accuracy = data.accuracyPercentage;
    String badgeText;
    Color badgeColor;
    Color badgeTextColor;

    if (accuracy >= 85) {
      badgeText = "High Proficiency";
      badgeColor = AppColors.green100;
      badgeTextColor = AppColors.green800;
    } else if (accuracy >= 60) {
      badgeText = "Moderate";
      badgeColor = AppColors.orange100;
      badgeTextColor = AppColors.orange800;
    } else {
      badgeText = "Requires Focus";
      badgeColor = AppColors.red100;
      badgeTextColor = AppColors.red800;
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray200.withAlpha(50),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data.subjectName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          20.hGap,
          Row(
            children: [
              _buildMetricItem("TESTS", "${data.attemptedTests}"),
              _buildMetricItem(
                "ACCURACY",
                "${accuracy.toInt()}%",
                color:
                    accuracy >= 85
                        ? AppColors.green500
                        : (accuracy < 60
                            ? AppColors.red500
                            : AppColors.orange500),
              ),
              _buildMetricItem("TOTAL Qs", "${data.totalQuestions}"),
            ],
          ),
          16.hGap,
          Row(
            children: [
              _buildMetricItem("ATTEMPTED", "${data.attemptedQuestions}"),
              _buildMetricItem("CORRECT", "${data.correctQuestions}"),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.gray400,
              letterSpacing: 0.5,
            ),
          ),
          4.hGap,
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.gray900,
            ),
          ),
        ],
      ),
    );
  }
}

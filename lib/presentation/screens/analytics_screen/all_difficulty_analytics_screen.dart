import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/domain/entities/overall_analytics_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/detailed_analytics/detailed_analytics_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/analytics_date_range_picker.dart';
import 'package:gpsc_prep_app/presentation/widgets/empty_state_ui.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/enums/difficulty_level.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class AllDifficultyAnalyticsScreen extends StatefulWidget {
  final List<Difficulty> difficultyData;

  const AllDifficultyAnalyticsScreen({required this.difficultyData, super.key});

  @override
  State<AllDifficultyAnalyticsScreen> createState() =>
      _AllDifficultyAnalyticsScreenState();
}

class _AllDifficultyAnalyticsScreenState
    extends State<AllDifficultyAnalyticsScreen> {
  DateTimeRange? _selectedDateRange;

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailedAnalyticsBloc, DetailedAnalyticsState>(
      builder: (context, state) {
        final data = state.difficultyData;
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
              "Detailed Difficulty Analysis",
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
                              LoadDetailedDifficultyEvent(
                                from: picked.start,
                                to: picked.end,
                              ),
                            );
                          },
                        ),
                        24.hGap,
                        if (data.isEmpty && !isLoading)
                          EmptyStateUi()
                        else ...[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Text(
                              "ACCURACY OVERVIEW",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gray500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          16.hGap,
                          _buildAccuracyOverview(data),
                          24.hGap,
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Text(
                              "PERFORMANCE METRICS",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gray500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          16.hGap,
                          ...data.map((d) => _buildPerformanceMetricCard(d)),
                        ],
                        40.hGap,
                      ],
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildAccuracyOverview(List<Difficulty> data) {
    // Sort data based on DifficultyLevel enum order
    final sortedData = List<Difficulty>.from(data);
    sortedData.sort((a, b) {
      if (a.difficultyLevel == null || b.difficultyLevel == null) return 0;
      return a.difficultyLevel!.index.compareTo(b.difficultyLevel!.index);
    });

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            sortedData.map((d) {
              Color color;
              DifficultyLevel? level = d.difficultyLevel;
              String levelName = level?.level ?? "UNKNOWN";

              if (level == DifficultyLevel.easy) {
                color = AppColors.green500;
              } else if (level == DifficultyLevel.mod) {
                color = AppColors.orange500;
              } else {
                color = AppColors.red500;
              }

              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        levelName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray400,
                        ),
                      ),
                      8.hGap,
                      Text(
                        "${d.accuracyPct.toInt()}%",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildPerformanceMetricCard(Difficulty data) {
    String levelName = data.difficultyLevel?.level ?? "Unknown";
    double accuracy = data.accuracyPct;
    Color levelColor;
    String badgeText;
    Color badgeColor;
    Color badgeTextColor;

    if (accuracy >= 85) {
      levelColor = AppColors.green500;
      badgeText = "High Proficiency";
      badgeColor = AppColors.green100;
      badgeTextColor = AppColors.green800;
    } else if (accuracy >= 60) {
      levelColor = AppColors.orange500;
      badgeText = "Moderate";
      badgeColor = AppColors.orange100;
      badgeTextColor = AppColors.orange800;
    } else {
      levelColor = AppColors.red500;
      badgeText = "Requires Focus";
      badgeColor = AppColors.red100;
      badgeTextColor = AppColors.red800;
    }

    return Container(
      margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$levelName Questions",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: levelColor,
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
              _buildMetricItem("TOTAL Qs", "${data.totalQuestions}"),
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
              _buildMetricItem("ATTEMPTED", "${data.attempted}"),
            ],
          ),
          16.hGap,
          Row(
            children: [
              _buildMetricItem("CORRECT", "${data.correctCount}"),
              _buildMetricItem("INCORRECT", "${data.incorrectCount}"),
              _buildMetricItem("NOT ATTEMPTED", "${data.notAttempted}"),
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

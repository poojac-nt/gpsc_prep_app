import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/domain/entities/overall_analytics_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/detailed_analytics/detailed_analytics_bloc.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:intl/intl.dart';

class AllQuestionTypesAnalyticsScreen extends StatefulWidget {
  final List<Difficulty> questionTypesData;

  const AllQuestionTypesAnalyticsScreen({
    required this.questionTypesData,
    super.key,
  });

  @override
  State<AllQuestionTypesAnalyticsScreen> createState() =>
      _AllQuestionTypesAnalyticsScreenState();
}

class _AllQuestionTypesAnalyticsScreenState
    extends State<AllQuestionTypesAnalyticsScreen> {
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

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray900,
              secondary: AppColors.primary,
            ),
            dividerTheme: const DividerThemeData(thickness: 0),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      if (mounted) {
        context.read<DetailedAnalyticsBloc>().add(
          LoadDetailedQuestionTypeEvent(from: picked.start, to: picked.end),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailedAnalyticsBloc, DetailedAnalyticsState>(
      builder: (context, state) {
        final data = state.questionTypeData;
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
              "Question Types Analysis",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body:
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        16.hGap,
                        _buildDatePickerTrigger(),
                        24.hGap,
                        if (data.isEmpty)
                          _buildEmptyState()
                        else ...[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Text(
                              "PERFORMANCE BREAKDOWN",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gray500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          16.hGap,
                          _buildPerformanceBreakdown(data),
                        ],
                        40.hGap,
                      ],
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildDatePickerTrigger() {
    final df = DateFormat('MMM dd, yyyy');
    String rangeText = "Select Date Range";
    if (_selectedDateRange != null) {
      rangeText =
          "${df.format(_selectedDateRange!.start)} - ${df.format(_selectedDateRange!.end)}";
    }

    return GestureDetector(
      onTap: _selectDateRange,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.gray200.withAlpha(150), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(15),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: AppColors.primary,
                size: 22.sp,
              ),
            ),
            16.wGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Analysis Period",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray500,
                    ),
                  ),
                  2.hGap,
                  Text(
                    rangeText,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.gray400,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceBreakdown(List<Difficulty> data) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.gray200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: data.length,
        separatorBuilder:
            (context, index) => Divider(color: AppColors.gray100, height: 1),
        itemBuilder: (context, index) {
          final item = data[index];
          return _buildTypeRow(item);
        },
      ),
    );
  }

  Widget _buildTypeRow(Difficulty data) {
    final accuracy = data.accuracyPct;
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

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.questionType?.type ?? "Unknown",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
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
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.gray900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.gray200.withAlpha(150), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.query_stats_rounded,
              size: 48.sp,
              color: AppColors.gray400,
            ),
          ),
          24.hGap,
          Text(
            "No Data Available",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          8.hGap,
          Text(
            "We couldn't find any analysis for the selected period. Try adjusting your date range.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.gray500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

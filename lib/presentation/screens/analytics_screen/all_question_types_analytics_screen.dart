import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/domain/entities/overall_analytics_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/detailed_analytics/detailed_analytics_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/analytics_date_range_picker.dart';
import 'package:gpsc_prep_app/presentation/widgets/empty_state_ui.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

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
                        AnalyticsDateRangePicker(
                          selectedRange: _selectedDateRange,
                          onRangeSelected: (picked) {
                            setState(() {
                              _selectedDateRange = picked;
                            });
                            context.read<DetailedAnalyticsBloc>().add(
                              LoadDetailedQuestionTypeEvent(
                                from: picked.start,
                                to: picked.end,
                              ),
                            );
                          },
                        ),
                        24.hGap,
                        if (data.isEmpty)
                          EmptyStateUi()
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
}

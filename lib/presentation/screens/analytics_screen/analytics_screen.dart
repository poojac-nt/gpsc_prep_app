import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/presentation/blocs/analytics/analytics_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/enums/date_range_enum.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String progressTrendRange = "Weekly";
  final List<List<Color>> gradientColors = [
    [Color(0xFF667eea), Color(0xFF764ba2)],
    [Color(0xFF06beb6), Color(0xFF48b1bf)],
    [Color(0xFFf857a6), Color(0xFFff5858)],
    [Color(0xFFffa751), Color(0xFFffe259)],
  ];

  @override
  void initState() {
    super.initState();
    final bloc = context.read<AnalyticsBloc>();
    bloc
      ..add(LoadSubjectMasteryEvent(AnalyticsRange.weekly))
      ..add(LoadDifficultyAnalyticsEvent(AnalyticsRange.weekly))
      ..add(LoadQuestionTypeAnalyticsEvent(AnalyticsRange.weekly))
      ..add(FetchTrendData());
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Rebuilding AnalyticsScreen');
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text("Performance Analytics", style: AppTexts.titleTextStyle),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          context.read<AnalyticsBloc>()
            ..add(ResetAnalyticsEvent())
            ..add(LoadSubjectMasteryEvent(AnalyticsRange.weekly))
            ..add(LoadDifficultyAnalyticsEvent(AnalyticsRange.weekly))
            ..add(LoadQuestionTypeAnalyticsEvent(AnalyticsRange.weekly))
            ..add(FetchTrendData());
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              BlocSelector<AnalyticsBloc, AnalyticsState, SubjectMasteryState>(
                selector: (state) => state.subjectMastery,
                builder:
                    (_, state) => _buildSubjectMasterySection(state: state),
              ),
              20.hGap,

              BlocSelector<
                AnalyticsBloc,
                AnalyticsState,
                DifficultyAnalyticsState
              >(
                selector: (state) => state.difficulty,
                builder:
                    (_, state) => _buildDifficultyAnalysisSection(state: state),
              ),
              20.hGap,

              BlocSelector<
                AnalyticsBloc,
                AnalyticsState,
                QuestionTypeAnalyticsState
              >(
                selector: (state) => state.questionTypes,
                builder: (_, state) => _buildQuestionTypesSection(state: state),
              ),
              20.hGap,

              BlocSelector<AnalyticsBloc, AnalyticsState, TrendDataState>(
                selector: (state) => state.trendData,
                builder:
                    (_, state) => _buildProgressTrendsSection(trendData: state),
              ),
              40.hGap,
            ],
          ).padAll(AppPaddings.defaultPadding),
        ),
      ),
    );
  }

  Widget _buildSubjectMasterySection({required SubjectMasteryState state}) {
    return TestModule(
      title: "Subject Mastery",
      fontSize: 18.sp,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRangeToggleGroup(
            state.range == AnalyticsRange.weekly ? "Weekly" : "Monthly",
            (val) {
              context.read<AnalyticsBloc>().add(
                LoadSubjectMasteryEvent(
                  val == "Weekly"
                      ? AnalyticsRange.weekly
                      : AnalyticsRange.monthly,
                ),
              );
            },
          ),
          12.wGap,
        ],
      ),
      cards: [
        if (state.isLoading)
          progressIndicator()
        else if (state.error != null)
          _buildErrorWidget(state.error!.message)
        else if (state.data.isEmpty)
          _buildEmptyWidget("No subject data available yet")
        else ...[
          10.hGap,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SUBJECT",
                style: AppTexts.subTitle.copyWith(
                  fontSize: 10.sp,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                "ACCURACY",
                style: AppTexts.subTitle.copyWith(
                  fontSize: 10.sp,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          10.hGap,
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.data.length > 2 ? 2 : state.data.length,
            separatorBuilder:
                (context, index) => Divider(height: 1, color: Colors.grey[100]),
            itemBuilder: (context, index) {
              return _buildSubjectItem(
                state.data[index].subjectName,
                state.data[index].accuracyPercentage,
              );
            },
          ),

          if (!state.isLoading && state.data.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      () => context.push(
                        AppRoutes.allSubjectsAnalyticsScreen,
                        extra: state.data,
                      ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(50.w, 30.h),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "View All",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ],
    );
  }

  Widget _buildSubjectItem(String name, double accuracy) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
          ),
          Spacer(),
          Text(
            "$accuracy%",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyAnalysisSection({
    required DifficultyAnalyticsState state,
  }) {
    return TestModule(
      title: "Difficulty Analysis",
      fontSize: 18.sp,
      trailing: _buildRangeToggleGroup(
        state.range == AnalyticsRange.weekly ? "Weekly" : "Monthly",
        (val) {
          context.read<AnalyticsBloc>().add(
            LoadDifficultyAnalyticsEvent(
              val == "Weekly" ? AnalyticsRange.weekly : AnalyticsRange.monthly,
            ),
          );
        },
      ),
      cards: [
        if (state.isLoading)
          progressIndicator()
        else if (state.error != null)
          _buildErrorWidget(state.error!.message)
        else if (state.data.isEmpty)
          _buildEmptyWidget("No difficulty data available yet")
        else ...[
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Overall Accuracy",
                    style: AppTexts.subTitle.copyWith(color: Colors.blueGrey),
                  ),
                  4.hGap,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${state.overallAccuracy}%",
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.bar_chart_rounded, color: Colors.blueGrey),
              ),
            ],
          ),
          25.hGap,
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.data.length,
            separatorBuilder: (context, index) => 10.hGap,
            itemBuilder: (context, index) {
              return _buildDifficultyBar(
                state.data[index].difficultyLevel!.level,
                state.data[index].accuracyPct,
                index,
              );
            },
          ),
          if (!state.isLoading && state.data.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      () => context.push(
                        AppRoutes.allDifficultyAnalyticsScreen,
                        extra: state.data,
                      ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(50.w, 30.h),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "View All",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ],
    );
  }

  Center progressIndicator() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.h),
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildDifficultyBar(String label, double value, int index) {
    final barColors = [
      AppColors.green500,
      AppColors.orange500,
      AppColors.red500,
      AppColors.primary,
    ];
    return Row(
      children: [
        SizedBox(
          width: 110.w,
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
          ),
        ),
        Expanded(
          child: Container(
            height: 10.h,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: barColors[index],
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
        ),
        20.wGap,
        Text(
          "$value%",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionTypesSection({
    required QuestionTypeAnalyticsState state,
  }) {
    return TestModule(
      title: "Question Types",
      fontSize: 18.sp,
      trailing: _buildRangeToggleGroup(
        state.range == AnalyticsRange.weekly ? "Weekly" : "Monthly",
        (val) {
          context.read<AnalyticsBloc>().add(
            LoadQuestionTypeAnalyticsEvent(
              val == "Weekly" ? AnalyticsRange.weekly : AnalyticsRange.monthly,
            ),
          );
        },
      ),
      cards: [
        if (state.isLoading)
          progressIndicator()
        else if (state.error != null)
          _buildErrorWidget(state.error!.message)
        else if (state.data.isEmpty)
          _buildEmptyWidget("No question type data available yet")
        else
          Column(
            children: [
              10.hGap,
              SizedBox(
                height: 180.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.data.length,
                  separatorBuilder: (context, index) => 12.wGap,
                  itemBuilder: (context, index) {
                    // Fixed gradient colors for each question type
                    final List<Color> cardGradient;
                    if (index == 0) {
                      cardGradient = [Color(0xFF667eea), Color(0xFF764ba2)];
                    } else if (index == 1) {
                      cardGradient = [Color(0xFF06beb6), Color(0xFF48b1bf)];
                    } else if (index == 2) {
                      cardGradient = [Color(0xFFf857a6), Color(0xFFff5858)];
                    } else {
                      cardGradient =
                          gradientColors[index % gradientColors.length];
                    }

                    return _buildTypeCard(
                      state.data[index].questionType!.type,
                      state.data[index].accuracyPct,
                      cardGradient,
                    );
                  },
                ),
              ),
            ],
          ),
        if (!state.isLoading && state.data.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed:
                    () => context.push(
                      AppRoutes.allQuestionTypesAnalyticsScreen,
                      extra: state.data,
                    ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(50.w, 30.h),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "View All",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTypeCard(
    String label,
    double value,
    List<Color> gradientColors,
  ) {
    return Container(
      width: 150.w,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withAlpha(77),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$value%",
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              4.hGap,
              Text(
                "Accuracy",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white.withAlpha(204),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTrendsSection({required TrendDataState trendData}) {
    return TestModule(
      title: "Progress Trends",
      fontSize: 18.sp,
      trailing: _buildRangeToggleGroup(progressTrendRange, (val) {
        setState(() => progressTrendRange = val);
      }),
      cards: [
        if (trendData.isLoading)
          progressIndicator()
        else if (trendData.error != null)
          _buildErrorWidget(trendData.error!.message)
        else if (trendData.data == null)
          _buildEmptyWidget("No trend data available yet")
        else ...[
          () {
            bool isWeekly = progressTrendRange == "Weekly";
            final data =
                isWeekly ? trendData.data!.weekly : trendData.data!.monthly;

            if (data.isEmpty) {
              return _buildEmptyWidget("No trend data available yet");
            }

            final labels =
                data.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final trend = entry.value;
                  if (isWeekly) {
                    if (trend.startDate.day != trend.endDate.day) {
                      return '${trend.startDate.day}/${trend.endDate.day}';
                    } else {
                      return '${trend.startDate.day}/${trend.startDate.month}';
                    }
                  } else {
                    final months = [
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'May',
                      'Jun',
                      'Jul',
                      'Aug',
                      'Sep',
                      'Oct',
                      'Nov',
                      'Dec',
                    ];
                    final monthName = months[trend.startDate.month - 1];
                    return 'W$index/$monthName';
                  }
                }).toList();

            final spots =
                data.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value.accuracy);
                }).toList();

            return Column(
              children: [
                20.hGap,
                SizedBox(
                  height: 220.h,
                  child: LineChart(
                    LineChartData(
                      maxY: 100,
                      minY: 0,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine:
                            (value) =>
                                FlLine(color: Colors.grey[100], strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor:
                              (touchedSpot) => Colors.black.withAlpha(80),
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                '${spot.y.toInt()}%',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 35.w,
                            interval: 25,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}%',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 25.sp,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() < labels.length) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 10.h),
                                  child: Text(
                                    labels[value.toInt()],
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter:
                                (spot, percent, barData, index) =>
                                    FlDotCirclePainter(
                                      radius: 4,
                                      color: Colors.white,
                                      strokeWidth: 2,
                                      strokeColor: AppColors.primary,
                                    ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withAlpha(51),
                                AppColors.primary.withAlpha(0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }(),
        ],
      ],
    );
  }

  Widget _buildRangeToggleGroup(
    String currentValue,
    Function(String) onChanged,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabToggle("Weekly", currentValue, onChanged),
          _buildTabToggle("Monthly", currentValue, onChanged),
        ],
      ),
    );
  }

  Widget _buildTabToggle(
    String label,
    String currentValue,
    Function(String) onTap,
  ) {
    bool isSelected = currentValue == label;
    return GestureDetector(
      onTap: () => onTap(label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.grey[500],
          ),
        ),
      ),
    );
  }

  // Helper widgets for error and empty states
  Widget _buildErrorWidget(String message) {
    return Padding(
      padding: EdgeInsets.all(20.h),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: Colors.red[300]),
          12.hGap,
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(String message) {
    return Padding(
      padding: EdgeInsets.all(20.h),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48.sp, color: Colors.grey[300]),
          12.hGap,
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

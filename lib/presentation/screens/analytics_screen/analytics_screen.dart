import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/domain/entities/overall_analytics_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/analytics/analytics_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String subjectMasteryRange = "Weekly";
  String difficultyAnalysisRange = "Weekly";
  String questionTypesRange = "Weekly";
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
    context.read<AnalyticsBloc>().add(FetchAnalyticsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text("Performance Analytics", style: AppTexts.titleTextStyle),
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnalyticsError) {
            return Center(
              child: Text(
                state.message.message,
                style: TextStyle(fontSize: 16.sp, color: Colors.red),
              ),
            );
          }
          if (state is AnalyticsLoaded) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildSubjectMasterySection(
                    subjectData: state.analyticsData.subjectScores,
                  ),
                  20.hGap,
                  _buildDifficultyAnalysisSection(
                    difficultyData: state.analyticsData.difficulty,
                    overallAccuracy: state.analyticsData.userAccuracyOverall,
                  ),
                  20.hGap,
                  _buildQuestionTypesSection(
                    questionTypeData: state.analyticsData.questionType,
                  ),
                  20.hGap,
                  _buildProgressTrendsSection(),
                  40.hGap,
                ],
              ).padAll(AppPaddings.defaultPadding),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSubjectMasterySection({
    required List<SubjectScore> subjectData,
  }) {
    return TestModule(
      title: "Subject Mastery",
      fontSize: 18.sp,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed:
                () => context.push(
                  AppRoutes.allSubjectsAnalyticsScreen,
                  extra: subjectData,
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
      cards: [
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
          itemCount: subjectData.length > 2 ? 2 : subjectData.length,
          separatorBuilder:
              (context, index) => Divider(height: 1, color: Colors.grey[100]),
          itemBuilder: (context, index) {
            return _buildSubjectItem(
              subjectData[index].subjectName,
              subjectData[index].accuracyPercentage,
            );
          },
        ),
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
    required List<Difficulty> difficultyData,
    required String overallAccuracy,
  }) {
    return TestModule(
      title: "Difficulty Analysis",
      fontSize: 18.sp,
      trailing: _buildRangeToggleGroup(difficultyAnalysisRange, (val) {
        setState(() => difficultyAnalysisRange = val);
      }),
      cards: [
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
                      "$overallAccuracy%",
                      style: TextStyle(
                        fontSize: 32.sp,
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
          itemCount: difficultyData.length,
          separatorBuilder: (context, index) => 10.hGap,
          itemBuilder: (context, index) {
            return _buildDifficultyBar(
              difficultyData[index].difficultyLevel!.level,
              difficultyData[index].accuracyPct,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDifficultyBar(String label, int value) {
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey[100],
              color: AppColors.primary,
              minHeight: 10.h,
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
    required List<Difficulty> questionTypeData,
  }) {
    return TestModule(
      title: "Question Types",
      fontSize: 18.sp,
      trailing: _buildRangeToggleGroup(questionTypesRange, (val) {
        setState(() => questionTypesRange = val);
      }),
      cards: [
        SizedBox(
          height: 180.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: questionTypeData.length,
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
                cardGradient = gradientColors[index % gradientColors.length];
              }

              return _buildTypeCard(
                questionTypeData[index].questionType!.type,
                questionTypeData[index].accuracyPct,
                cardGradient,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTypeCard(String label, int value, List<Color> gradientColors) {
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
                  fontSize: 32.sp,
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

  Widget _buildProgressTrendsSection() {
    bool isWeekly = progressTrendRange == "Weekly";
    final labels =
        isWeekly
            ? ['M', 'T', 'W', 'T', 'F', 'S', 'S']
            : ['W1', 'W2', 'W3', 'W4'];
    final spots =
        isWeekly
            ? const [
              FlSpot(0, 40),
              FlSpot(1, 60),
              FlSpot(2, 45),
              FlSpot(3, 70),
              FlSpot(4, 55),
              FlSpot(5, 85),
              FlSpot(6, 40),
            ]
            : const [
              FlSpot(0, 50),
              FlSpot(1, 75),
              FlSpot(2, 60),
              FlSpot(3, 90),
            ];

    return TestModule(
      title: "Progress Trends",
      fontSize: 18.sp,
      trailing: _buildRangeToggleGroup(progressTrendRange, (val) {
        setState(() => progressTrendRange = val);
      }),
      cards: [
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
                    (value) => FlLine(color: Colors.grey[100], strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => Colors.black.withAlpha(80),
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
                      if (value.toInt() >= 0 && value.toInt() < labels.length) {
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
                        (spot, percent, barData, index) => FlDotCirclePainter(
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
}

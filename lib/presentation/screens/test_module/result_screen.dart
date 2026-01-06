import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/config/environment.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/domain/entities/daily_test_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/bar_chart/bar_chart_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/connectivity_bloc/connectivity_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/pie_chart/pie_chart_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/pie_chart/pie_chart_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/question/question_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/test/test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/test/test_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/test/test_state.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/question/question_cubit.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/test/test_cubit.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/test/test_cubit_state.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/banner_ad.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import '../../blocs/dashboard/dashboard_bloc.dart';
import '../../blocs/dashboard/dashboard_bloc_event.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    this.isFromTestScreen = false,
    required this.dailyTestModel,
  });

  final bool isFromTestScreen;
  final DailyTestModel dailyTestModel;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.isFromTestScreen) {
      context.read<TestBloc>().add(
        FetchSingleTestResultWithTopScoreEvent(
          testId: widget.dailyTestModel.id,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        context.read<ConnectivityBloc>().add(CheckConnectivity());
        if (widget.isFromTestScreen) {
          context.read<DashboardBloc>().add(FetchAttemptedTests());
        }
        context.go(AppRoutes.studentDashboard);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Result - ${widget.dailyTestModel.name}',
            style: AppTexts.titleTextStyle.copyWith(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: BlocBuilder<TestBloc, TestState>(
          builder: (context, testBlocState) {
            if (testBlocState is TestSubmitted) {
              return BlocBuilder<TestCubit, TestCubitSubmitted>(
                builder: (context, testCubitState) {
                  final data = _TestResultData(
                    correct: testCubitState.correctAnswers ?? 0,
                    incorrect: testCubitState.inCorrectAnswers ?? 0,
                    skipped: testCubitState.notAttemptedQuestions ?? 0,
                    attempted: testCubitState.attemptedQuestions ?? 0,
                    total: testCubitState.totalQuestions ?? 0,
                    score: testCubitState.score ?? 0.0,
                    topScore: 0.0,
                  );
                  return _buildSummaryBody(
                    context,
                    data,
                    testCubitState.questions,
                    testCubitState.isAnswerCorrect,
                    testCubitState.answeredStatus,
                    testCubitState.selectedOption,
                  );
                },
              );
            }
            if (testBlocState is SingleResultWithTopScoreSuccess) {
              final result = testBlocState.result;
              final data = _TestResultData(
                correct: result.correctAnswers,
                incorrect: result.inCorrectAnswers,
                skipped: result.notAttemptedQuestions,
                attempted: result.attemptedQuestions,
                total: result.totalQuestions,
                score: result.score,
                topScore: result.topScore,
              );
              return _buildSummaryBody(context, data, null, null, null, null);
            }
            if (testBlocState is SingleResultLoading) {
              return Center(child: CircularProgressIndicator());
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSummaryBody(
    BuildContext context,
    _TestResultData data,
    dynamic questions,
    dynamic isCorrect,
    dynamic answeredStatus,
    dynamic selectedOption,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          10.hGap,
          // Correctness & Stats Module
          TestModule(
            title: "Result Summary",
            iconSize: 26.sp,
            fontSize: 20.sp,
            cards: [
              20.hGap,
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 200.h,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 70.r,
                        startDegreeOffset: -90,
                        sections: [
                          PieChartSectionData(
                            color: Colors.green,
                            value: data.correct.toDouble(),
                            title: '',
                            radius: 12,
                          ),
                          PieChartSectionData(
                            color: Colors.red,
                            value: data.incorrect.toDouble(),
                            title: '',
                            radius: 12,
                          ),
                          PieChartSectionData(
                            color: Colors.grey.shade300,
                            value: data.skipped.toDouble(),
                            title: '',
                            radius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    "Correctness",
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              30.hGap,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statItem(
                    data.total.toString(),
                    "Total",
                    Colors.grey.shade700,
                  ),
                  _statItem(
                    data.attempted.toString(),
                    "Attempted",
                    Colors.blue.shade700,
                  ),
                  _statItem(
                    data.correct.toString(),
                    "Correct",
                    Colors.green.shade600,
                  ),
                  _statItem(
                    data.incorrect.toString(),
                    "Incorrect",
                    Colors.red.shade600,
                  ),
                  _statItem(
                    data.skipped.toString(),
                    "Skipped",
                    Colors.grey.shade400,
                  ),
                ],
              ),
              20.hGap,
            ],
          ).padAll(AppPaddings.defaultPadding),

          // Test Performance Module
          TestModule(
            title: "Test Performance",
            iconSize: 26.sp,
            fontSize: 20.sp,
            prefixIcon: Icons.emoji_events,
            iconColor: Colors.amber,
            cards: [
              20.hGap,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _performanceItem(
                    label: "Score",
                    value: data.score.toStringAsFixed(1),
                    percentage: (data.score /
                            (widget.dailyTestModel.totalMarks == 0
                                ? 1
                                : widget.dailyTestModel.totalMarks))
                        .clamp(0.0, 1.0),
                    color: Colors.blue,
                  ),
                  _performanceItem(
                    label: "Accuracy",
                    value:
                        "${((data.correct / (data.total == 0 ? 1 : data.total)) * 100).toStringAsFixed(0)}%",
                    percentage: (data.correct /
                            (data.total == 0 ? 1 : data.total))
                        .clamp(0.0, 1.0),
                    color: Colors.purpleAccent,
                  ),
                  _performanceItem(
                    label: "Topper's Score",
                    value: data.topScore.toStringAsFixed(1),
                    percentage: 1.0,
                    color: Colors.pinkAccent,
                  ),
                ],
              ),
              20.hGap,
            ],
          ).padAll(AppPaddings.defaultPadding),

          // Action Buttons
          if (questions != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppPaddings.defaultPadding,
                vertical: 10.sp,
              ),
              child: Column(
                children: [
                  ActionButton(
                    text: "Download Detailed Report",
                    onTap: () {
                      final blocState = context.read<QuestionBloc>().state;
                      context.push(
                        AppRoutes.questionPreviewScreen,
                        extra: QuestionPreviewScreenArgs(
                          questions:
                              blocState is McqQuestionLoaded
                                  ? blocState.questionsModels
                                  : [],
                          testName: widget.dailyTestModel.name,
                        ),
                      );
                    },
                  ),
                  10.hGap,
                  ActionButton(
                    text: "Review Answers",
                    fontColor: Colors.white,
                    onTap: () {
                      context.read<QuestionCubit>().reviewTest(
                        questions: questions,
                        isCorrect: isCorrect,
                        answeredStatus: answeredStatus,
                        selectedOption: selectedOption,
                      );
                      context.read<PieChartBloc>().add(
                        FetchPerformanceSummary(
                          testId: widget.dailyTestModel.id,
                        ),
                      );
                      context.read<BarChartBloc>().add(
                        FetchOptionMatrix(testId: widget.dailyTestModel.id),
                      );
                      context.push(
                        AppRoutes.testScreen,
                        extra: TestScreenArgs(
                          isFromResult: true,
                          dailyTestModel: widget.dailyTestModel,
                          language: null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
          if (Environment.isProduction)
            BannerAdWidget(adUnitId: AdUnitIds.bannerUnitId),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 45.w,
          height: 45.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
        ),
        8.hGap,
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
        ),
      ],
    );
  }

  Widget _performanceItem({
    required String label,
    required String value,
    required double percentage,
    required Color color,
  }) {
    return Column(
      children: [
        SizedBox(
          height: 60.w,
          width: 60.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 24.w,
                  startDegreeOffset: -90,
                  sections: [
                    PieChartSectionData(
                      color: color,
                      value: percentage * 100,
                      title: '',
                      radius: 6,
                    ),
                    PieChartSectionData(
                      color: Colors.grey.shade200,
                      value: (1 - percentage) * 100,
                      title: '',
                      radius: 6,
                    ),
                  ],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        10.hGap,
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
        ),
      ],
    );
  }
}

class _TestResultData {
  final int correct;
  final int incorrect;
  final int skipped;
  final int attempted;
  final int total;
  final double score;
  final double topScore;

  _TestResultData({
    required this.correct,
    required this.incorrect,
    required this.skipped,
    required this.attempted,
    required this.total,
    required this.score,
    required this.topScore,
  });
}

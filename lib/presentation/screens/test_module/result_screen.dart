import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/config/environment.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/domain/entities/detailed_test_result_model.dart';
import 'package:gpsc_prep_app/domain/entities/difficulty_wise_review_per_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_with_top_score_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/bar_chart/bar_chart_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/connectivity_bloc/connectivity_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/pie_chart/pie_chart_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/question/question_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/result/result_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/test/test_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/question/question_cubit.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/test/test_cubit.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/test/test_cubit_state.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/banner_ad.dart';
import 'package:gpsc_prep_app/presentation/widgets/difficulty_wise_bar_chart.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/services/test_link_generator.dart';

import '../../blocs/daily_test/daily_test_bloc.dart';
import '../../blocs/dashboard/dashboard_bloc.dart';
import '../../blocs/prelims/prelims_test_bloc.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    this.isFromTestScreen = false,
    required this.testModel,
  });

  final bool isFromTestScreen;
  final TestModel testModel;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    final isInternetAvailable =
        context.read<ConnectivityBloc>().state is ConnectivityOnline;
    if (isInternetAvailable) {
      context.read<ResultBloc>().add(FetchResultData(widget.testModel.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) return;
        context.read<ConnectivityBloc>().add(CheckConnectivity());
        if (widget.isFromTestScreen) {
          context.read<DashboardBloc>().add(FetchDashboardAnalytics());
          if (widget.testModel.testType == TestType.mcq) {
            context.read<DailyTestBloc>().add(FetchTests());
          } else if (widget.testModel.testType == TestType.prelims) {
            context.read<PrelimsTestBloc>().add(FetchPrelimsTest());
          }
        }
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
            'Result - ${widget.testModel.name}',
            style: AppTexts.titleTextStyle.copyWith(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: BlocBuilder<TestBloc, TestState>(
          builder: (context, testBlocState) {
            if (testBlocState is TestSubmitted && widget.isFromTestScreen) {
              return BlocBuilder<TestCubit, TestCubitSubmitted>(
                builder: (context, testCubitState) {
                  return BlocBuilder<ResultBloc, ResultState>(
                    builder: (context, resultState) {
                      final isOnline =
                          context.read<ConnectivityBloc>().state
                              is ConnectivityOnline;
                      final serverResult = testBlocState.serverResult;
                      final data = _TestResultData(
                        correct:
                            isOnline
                                ? (serverResult?.correctAnswers ??
                                    testCubitState.correctAnswers ??
                                    0)
                                : (testCubitState.correctAnswers ?? 0),
                        incorrect:
                            isOnline
                                ? (serverResult?.inCorrectAnswers ??
                                    testCubitState.inCorrectAnswers ??
                                    0)
                                : (testCubitState.inCorrectAnswers ?? 0),
                        skipped:
                            isOnline
                                ? (serverResult?.notAttemptedQuestions ??
                                    testCubitState.notAttemptedQuestions ??
                                    0)
                                : (testCubitState.notAttemptedQuestions ?? 0),
                        attempted:
                            isOnline
                                ? (serverResult?.attemptedQuestions ??
                                    testCubitState.attemptedQuestions ??
                                    0)
                                : (testCubitState.attemptedQuestions ?? 0),
                        total:
                            isOnline
                                ? (serverResult?.totalQuestions ??
                                    testCubitState.totalQuestions ??
                                    0)
                                : (testCubitState.totalQuestions ?? 0),
                        score:
                            isOnline
                                ? (serverResult?.score ??
                                    testCubitState.score ??
                                    0.0)
                                : (testCubitState.score ?? 0.0),
                        userRank:
                            isOnline
                                ? (serverResult?.userRank ??
                                    testCubitState.userRank ??
                                    0)
                                : (testCubitState.userRank ?? 0),
                        topScore:
                            isOnline ? (serverResult?.topScore ?? 0.0) : 0.0,
                      );

                      return _buildSummaryBody(
                        context,
                        data,
                        testCubitState.questions,
                        testCubitState.isAnswerCorrect,
                        testCubitState.answeredStatus,
                        testCubitState.selectedOption,
                        testCubitState.batchResults,
                        testCubitState.timePerQuestion,
                        isOnline && resultState is ResultDataSuccess
                            ? resultState.result!.difficultyWiseReview
                            : null,
                        isOnline && resultState is ResultDataSuccess
                            ? resultState.result!.questionTypeReview
                            : null,
                        isOnline && resultState is ResultDataSuccess
                            ? resultState.result!.subjectWiseReview
                            : null,
                        isOnline && resultState is ResultDataSuccess
                            ? resultState.result
                            : null,
                      );
                    },
                  );
                },
              );
            }
            return BlocBuilder<ResultBloc, ResultState>(
              builder: (context, resultState) {
                if (resultState is ResultDataSuccess) {
                  final result = resultState.result;
                  final data = _TestResultData(
                    correct: result?.correctAnswers ?? 0,
                    incorrect: result?.inCorrectAnswers ?? 0,
                    skipped: result?.notAttemptedQuestions ?? 0,
                    attempted: result?.attemptedQuestions ?? 0,
                    total: result?.totalQuestions ?? 0,
                    score: result?.score ?? 0.0,
                    topScore: result?.topScore ?? 0.0,
                    userRank: result?.userRank ?? 0,
                  );
                  return _buildSummaryBody(
                    context,
                    data,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    resultState.result!.difficultyWiseReview,
                    resultState.result!.questionTypeReview,
                    resultState.result!.subjectWiseReview,
                    resultState.result,
                  );
                }
                if (resultState is ResultLoading) {
                  return Center(child: CircularProgressIndicator());
                }
                return SizedBox.shrink();
              },
            );
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
    List<DetailedTestResult>? detailedResults,
    List<int>? timePerQuestion,
    List<TestReviewAnalytics>? reviewByDifficulty,
    List<TestReviewAnalytics>? reviewByQuestionType,
    List<TestReviewAnalytics>? reviewBySubject,
    TestResultWithTopScoreModel? performanceSummary,
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
                    label: "Rank",
                    value: data.userRank.toString(),
                    percentage: 1.0,
                    color: Colors.blue,
                  ),
                  _performanceItem(
                    label: "Score",
                    value: data.score.toStringAsFixed(1),
                    percentage: (data.score /
                            (widget.testModel.totalMarks == 0
                                ? 1
                                : widget.testModel.totalMarks))
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

          // Difficulty Analysis Module
          if (reviewByDifficulty != null && _hasValidData(reviewByDifficulty))
            TestModule(
              title: "Difficulty Analysis",
              iconSize: 26.sp,
              fontSize: 20.sp,
              prefixIcon: Icons.analytics,

              iconColor: Colors.deepPurpleAccent,
              cards: [20.hGap, AnalyticsBarChart(data: reviewByDifficulty)],
            ).padAll(AppPaddings.defaultPadding),
          // Question Type Analysis Module
          if (reviewByQuestionType != null &&
              _hasValidData(reviewByQuestionType))
            TestModule(
              title: "Question Type Analysis",
              iconSize: 26.sp,
              fontSize: 20.sp,
              prefixIcon: Icons.bar_chart,
              iconColor: AppColors.primary,
              cards: [20.hGap, AnalyticsBarChart(data: reviewByQuestionType)],
            ).padAll(AppPaddings.defaultPadding),
          if (reviewBySubject != null && _hasValidData(reviewBySubject))
            TestModule(
              title: "Subject Analysis",
              iconSize: 26.sp,
              fontSize: 20.sp,
              prefixIcon: Icons.stacked_bar_chart,
              iconColor: Colors.brown,
              cards: [20.hGap, AnalyticsBarChart(data: reviewBySubject)],
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
                          testName: widget.testModel.name,
                          performanceSummary: performanceSummary,
                          testModel: widget.testModel,
                          detailedResults: detailedResults,
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
                        timePerQuestion:
                            timePerQuestion ??
                            detailedResults?.map((e) => e.timeSpent).toList() ??
                            List.generate(questions.length, (_) => 0),
                      );
                      context.read<PieChartBloc>().add(
                        FetchPerformanceSummary(testId: widget.testModel.id),
                      );
                      context.read<BarChartBloc>().add(
                        FetchOptionMatrix(testId: widget.testModel.id),
                      );
                      context.push(
                        AppRoutes.testScreen,
                        extra: TestScreenArgs(
                          isFromResult: true,
                          testModal: widget.testModel,
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

  bool _hasValidData(List<TestReviewAnalytics>? list) {
    if (list == null || list.isEmpty) return false;
    return list.any(
      (item) =>
          item.attemptedCount > 0 ||
          item.correctCount > 0 ||
          item.incorrectCount > 0,
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
  final int userRank;

  _TestResultData({
    required this.correct,
    required this.incorrect,
    required this.skipped,
    required this.attempted,
    required this.total,
    required this.score,
    required this.topScore,
    required this.userRank,
  });
}

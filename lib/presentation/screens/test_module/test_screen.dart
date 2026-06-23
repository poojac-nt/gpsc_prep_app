import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/config/environment.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/data/repositories/prelims_progress_repository.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/bar_chart/bar_chart_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/question/question_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/test/test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/timer/timer_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/dashboard/widgets/custom_progress_bar.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/question/question_cubit.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/question/question_cubit_state.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/test/test_cubit.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/widgets/question_indicator.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/widgets/question_navigator_btn.dart';
import 'package:gpsc_prep_app/presentation/widgets/action_button.dart';
import 'package:gpsc_prep_app/presentation/widgets/bar_chart.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/custom_alertdialog.dart';
import 'package:gpsc_prep_app/presentation/widgets/elevated_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/utils/extensions/question_markdown.dart';
import 'package:gpsc_prep_app/utils/services/ad_service.dart';
import 'package:gpsc_prep_app/utils/services/test_link_generator.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../domain/entities/test_model.dart';
import '../../../utils/enums/user_role.dart';
import '../../blocs/pie_chart/pie_chart_bloc.dart';
import '../../widgets/pie_chart.dart';
import 'cubit/test/test_cubit_state.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({
    super.key,
    this.isFromResult = false,
    required this.language,
    required this.dailyTestModel,
    this.hasPrelimsProgress = false,
  });

  final bool isFromResult;
  final String? language;
  final TestModel dailyTestModel;
  final bool hasPrelimsProgress;

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late QuestionLanguageData question;
  bool _initialized = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    final bloc = context.read<TimerBloc>();
    if (widget.isFromResult) {
      bloc.add(TimerStop());
    } else {
      bloc.add(TimerReset());
      context.read<QuestionBloc>().add(
        LoadMcqQuestion(widget.dailyTestModel.id, widget.language),
      );
    }
    super.initState();
  }

  int totalTime(BuildContext context) {
    var timerState = context.read<TimerBloc>().state;
    int mins = timerState is TimerStopped ? timerState.totalMins : 0;
    int secs = timerState is TimerStopped ? timerState.totalSecs : 0;
    final timeSpent = (mins * 60) + secs;
    return timeSpent;
  }

  bool isQuestionNotAttempted(PieChartResultSuccess state, int questionId) {
    final attemptedStats = state.attemptedCounts.firstWhere(
      (e) => e.questionId == questionId,
    );

    return attemptedStats.attemptedCount == 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TimerBloc, TimerState>(
      listener: (context, state) {
        if (state is TimerStopped) {
          if (widget.isFromResult) return;
          // Get data from QuestionCubit
          final questionCubitState = context.read<QuestionCubit>().state;
          if (questionCubitState is! McqQuestionCubitLoaded) return;

          // Get data from QuestionBloc
          final questionBlocState = context.read<QuestionBloc>().state;
          if (questionBlocState is! McqQuestionLoaded) return;

          context.read<TestCubit>().calculateAndEmitTestResult(
            questionsModel: questionCubitState.questionModel,
            questions: questionCubitState.questions,
            languageCode: widget.language!,
            testId: widget.dailyTestModel.id,
            selectedOption: questionCubitState.selectedOption,
            answeredStatus: questionCubitState.answeredStatus,
            timePerQuestion: questionCubitState.timePerQuestion,
            marks: questionBlocState.marks,
            minSpent: state.totalMins,
            secSpent: state.totalSecs,
          );
        }
      },
      child: PopScope(
        canPop: widget.isFromResult,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: Text(
                widget.dailyTestModel.name,
                style: AppTexts.titleTextStyle,
              ),
            ),
            actions: [
              // Language selector (only show during active test, not in review mode)
              if (!widget.isFromResult)
                BlocBuilder<QuestionCubit, QuestionCubitState>(
                  builder: (context, questionState) {
                    if (questionState is! McqQuestionCubitLoaded) {
                      return SizedBox.shrink();
                    }

                    // Determine available languages from TestModel.allowedLanguages
                    final List<String> allowed =
                        widget.dailyTestModel.allowedLanguages ?? [];
                    // Ensure English is always included and cannot be removed
                    final Set<String> languageSet = {};
                    languageSet.addAll(allowed);
                    final List<String> availableLanguages = languageSet
                        .toList();

                    // Only show if more than one language is available
                    if (availableLanguages.length <= 1) {
                      return SizedBox.shrink();
                    }

                    // Get current language character
                    String getLanguageChar(String lang) {
                      switch (lang) {
                        case 'en':
                          return 'A';
                        case 'hi':
                          return 'अ';
                        case 'gj':
                          return 'અ';
                        default:
                          return 'A';
                      }
                    }

                    // Get next language in the cycle
                    void switchToNextLanguage() {
                      final currentIndex = availableLanguages.indexOf(
                        questionState.currentLanguage,
                      );
                      final nextIndex =
                          (currentIndex + 1) % availableLanguages.length;
                      final nextLanguage = availableLanguages[nextIndex];
                      context.read<QuestionCubit>().switchLanguage(
                        nextLanguage,
                      );
                    }

                    return IconButton(
                      onPressed: switchToNextLanguage,
                      icon: Text(
                        getLanguageChar(questionState.currentLanguage),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      tooltip:
                          'Switch Language (${availableLanguages.map((l) {
                            switch (l) {
                              case 'en':
                                return 'English';
                              case 'hi':
                                return 'हिंदी';
                              case 'gj':
                                return 'ગુજરાતી';
                              default:
                                return '';
                            }
                          }).join(', ')})',
                    );
                  },
                ),

              // Show pause button ONLY for Prelims tests
              if (!widget.isFromResult && _isPrelimsTest())
                IconButton(
                  icon: const Icon(Icons.pause_circle_outline),
                  onPressed: () => _handlePause(context),
                  tooltip: "Pause Test",
                ),

              widget.isFromResult
                  ? TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: Text(
                        "Back to Result",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.black),
                      ),
                      child: IntrinsicWidth(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined, size: 18.sp),
                            5.wGap,
                            BlocBuilder<TimerBloc, TimerState>(
                              builder: (context, state) {
                                if (state is TimerRunning) {
                                  return Text(
                                    formatRemainingTime(
                                      remainingMinutes: state.remainingMinutes,
                                      remainingSeconds: state.remainingSeconds,
                                    ),
                                    style: TextStyle(
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                        // FIXED WIDTH DIGITS
                                      ],
                                    ),
                                  );
                                }
                                if (state is TimerStopped) {
                                  getIt<LogHelper>().w(
                                    state.totalMins.toString(),
                                  );
                                  getIt<LogHelper>().w(
                                    state.totalSecs.toString(),
                                  );
                                  return SizedBox.shrink();
                                }
                                return Text('00:00');
                              },
                            ),
                          ],
                        ),
                      ),
                    ).padSymmetric(horizontal: 10.w),
            ],
          ),
          body: BlocListener<TestCubit, TestCubitSubmitted>(
            listener: (context, state) {
              context.read<TestBloc>().add(
                SubmitTest(
                  widget.dailyTestModel.id,
                  state.questions,
                  state.selectedOption,
                  state.answeredStatus,
                  state.totalQuestions,
                  state.correctAnswers,
                  state.inCorrectAnswers,
                  state.attemptedQuestions,
                  state.notAttemptedQuestions,
                  state.score,
                  state.timeSpent,
                  state.batchResults,
                  timePerQuestion: state.timePerQuestion,
                ),
              );
              final timerState = context.read<TimerBloc>().state;
              final questionCubitState = context.read<QuestionCubit>().state;

              if (timerState is TimerStopped && !timerState.isManual) {
                _buildAutoSubmitDialog(context, state);
              } else if (questionCubitState is McqQuestionCubitLoaded &&
                  questionCubitState.isQuitTest) {
                final role = getIt<CacheManager>().getUserRole();
                if (role == UserRole.admin) {
                  context.go(AppRoutes.adminDashboard);
                } else if (role == UserRole.mentor) {
                  context.go(AppRoutes.mentorDashboard);
                } else {
                  context.go(AppRoutes.studentDashboard);
                }
              } else {
                Environment.isDevelopment
                    ? null
                    : AdService().showInterstitialAd();
                context.pushReplacement(
                  AppRoutes.resultScreen,
                  extra: ResultScreenArgs(
                    isFromTest: true,
                    testModal: widget.dailyTestModel,
                  ),
                );
              }
            },
            child: BlocConsumer<QuestionBloc, QuestionState>(
              listener: (context, state) {
                if (state is McqQuestionLoaded && !_initialized) {
                  _initialized = true;

                  if (widget.isFromResult) {
                    context.read<QuestionCubit>().initialize(
                      state.questions,
                      state.questionsModels,
                      widget.language!,
                    );
                  } else {
                    context.read<QuestionCubit>()
                      ..reset()
                      ..initialize(
                        state.questions,
                        state.questionsModels,
                        widget.language!,
                      );

                    // If this a Prelims test with saved progress, load it
                    if (widget.hasPrelimsProgress) {
                      final userId = getIt<CacheManager>().getUserId();
                      final testId = widget.dailyTestModel.id;
                      final loaded = context
                          .read<QuestionCubit>()
                          .loadPrelimsProgress(userId, testId);

                      if (loaded) {
                        final progress = getIt<PrelimsProgressRepository>()
                            .getProgress(userId, testId);
                        if (progress != null) {
                          context.read<TimerBloc>().add(
                            TimerStartWithRemaining(
                              progress.remainingTimeInSeconds,
                            ),
                          );

                          if (_isPrelimsTest()) {
                            getIt<TestRepository>().updateUserTestStatus(
                              testId: widget.dailyTestModel.id,
                              status: 'in_progress',
                            );
                          }
                          return; // Skip normal TimerStart
                        }
                      }
                    }

                    // Normal start
                    context.read<TimerBloc>().add(
                      TimerStart(testDuration: widget.dailyTestModel.duration),
                    );

                    if (_isPrelimsTest()) {
                      getIt<TestRepository>().updateUserTestStatus(
                        testId: widget.dailyTestModel.id,
                        status: 'in_progress',
                      );
                    }
                  }
                }
              },
              builder: (context, state) {
                if (state is QuestionLoading) {
                  return _buildWhenLoading();
                }

                if (state is McqQuestionLoaded) {
                  final marks = state.marks;
                  final subjects = state.subjects;
                  final topics = state.topics;
                  final difficultyLevel = state.difficultyLevel;
                  return BlocBuilder<QuestionCubit, QuestionCubitState>(
                    builder: (context, state) {
                      if (state is! McqQuestionCubitLoaded) {
                        return SizedBox.shrink();
                      }
                      final currentIndex = state.currentIndex;
                      final question = state.questions[currentIndex];

                      final selectedAnswer = state.selectedOption[currentIndex];
                      final visibleIndexes = context
                          .read<QuestionCubit>()
                          .visibleQuestionIndexes(state.questions.length);
                      return SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            CustomProgressBar(
                              titleText:
                                  "Question ${state.currentIndex + 1} of ${state.questions.length}",
                              value: state.progress,
                              labelText: "${state.answered} Answered",
                            ),
                            if (!state.isReview) ...[
                              20.hGap,
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    state.isReview
                                        ? SizedBox.shrink()
                                        : Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                right: 25.w,
                                              ),
                                              child: ActionButton(
                                                text: "Quit Test",
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => CustomAlertdialog(
                                                      title: "Confirm Exit",
                                                      mainContent:
                                                          "Do you really want to leave the test in between?",
                                                      content:
                                                          "Your answers so far won’t be saved, you won’t be able to resume this test later.",
                                                      actions: [
                                                        TextButton(
                                                          child: Text(
                                                            "Cancel",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey[700],
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                              context,
                                                            ).pop(); // Close dialog
                                                          },
                                                        ),
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .redAccent,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            "Yes, Leave",
                                                            style: AppTexts
                                                                .title
                                                                .copyWith(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                          ),
                                                          onPressed: () async {
                                                            if (_isPrelimsTest()) {
                                                              final testId = widget
                                                                  .dailyTestModel
                                                                  .id;
                                                              final userId =
                                                                  getIt<
                                                                        CacheManager
                                                                      >()
                                                                      .getUserId();
                                                              await getIt<
                                                                    PrelimsProgressRepository
                                                                  >()
                                                                  .deleteProgress(
                                                                    userId,
                                                                    testId,
                                                                  );
                                                              await getIt<
                                                                    TestRepository
                                                                  >()
                                                                  .deleteUserTest(
                                                                    testId:
                                                                        testId,
                                                                  );
                                                            }
                                                            if (!context
                                                                .mounted) {
                                                              return;
                                                            }
                                                            context
                                                                .pop(); // Close dialog
                                                            context
                                                                .pop(); // Close TestScreen and go back to Instructions/List
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                    100.wGap,
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 8.w),
                                        child: ActionButton(
                                          text: "Submit Test",
                                          onTap: () {
                                            var time = totalTime(context);
                                            _buildSubmitDialog(
                                              context,
                                              state,
                                              time,
                                              marks,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            20.hGap,
                            TestModule(
                              title: "Question ${state.currentIndex + 1} ",
                              cards: [
                                question.questionTxt.toQuestionWidget(),
                                10.hGap,
                                ListView.builder(
                                  itemCount: state.options.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final option = state.options[index];

                                    // Convert stored identifier to actual option text
                                    String? selectedOptionText;
                                    if (selectedAnswer != null) {
                                      switch (selectedAnswer.toUpperCase()) {
                                        case 'A':
                                          selectedOptionText = question.optA;
                                          break;
                                        case 'B':
                                          selectedOptionText = question.optB;
                                          break;
                                        case 'C':
                                          selectedOptionText = question.optC;
                                          break;
                                        case 'D':
                                          selectedOptionText = question.optD;
                                          break;
                                      }
                                    }

                                    final isSelected =
                                        selectedOptionText == option;
                                    Color? tileColor;
                                    Color? textColor;

                                    final correctAnswer =
                                        question.correctAnswer;

                                    // Redesigned Review Mode Option Card
                                    if (state.isReview) {
                                      final isCorrect = option == correctAnswer;
                                      final isWrongSelection =
                                          isSelected && !isCorrect;
                                      final isMissedCorrect =
                                          !isSelected && isCorrect;

                                      Color backgroundColor = Colors.white;
                                      Color borderColor = Colors.grey.shade300;
                                      Widget? trailingIcon;

                                      if (isCorrect && isSelected) {
                                        backgroundColor = Colors.green.shade50;
                                        borderColor = Colors.green;
                                        trailingIcon = Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        );
                                      } else if (isWrongSelection) {
                                        backgroundColor = Colors.red.shade50;
                                        borderColor = Colors.red;
                                        trailingIcon = Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                        );
                                      } else if (isMissedCorrect) {
                                        backgroundColor = Colors.green.shade50;
                                        borderColor = Colors.green.shade300;
                                        trailingIcon = Icon(
                                          Icons.info_outline,
                                          color: Colors.green,
                                        );
                                      }

                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                          vertical: 6.h,
                                        ),
                                        padding: EdgeInsets.all(16.w),
                                        decoration: BoxDecoration(
                                          color: backgroundColor,
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          border: Border.all(
                                            color: borderColor,
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            if (isSelected || isMissedCorrect)
                                              BoxShadow(
                                                color: borderColor.withValues(
                                                  alpha: 0.1,
                                                ),
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                option,
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  color: Colors.black87,
                                                  fontWeight:
                                                      isSelected || isCorrect
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            if (trailingIcon != null) ...[
                                              10.wGap,
                                              trailingIcon,
                                            ],
                                          ],
                                        ),
                                      );
                                    }

                                    // Standard mode (RadioGroup remains for selection)
                                    return RadioGroup<String>(
                                      groupValue: selectedOptionText,
                                      onChanged: (value) {
                                        state.isReview
                                            ? null
                                            : context
                                                  .read<QuestionCubit>()
                                                  .answerQuestion(value);
                                      },
                                      child: BorderedContainer(
                                        borderColor: tileColor,
                                        padding: EdgeInsets.zero,
                                        radius: BorderRadius.circular(10),
                                        child: RadioListTile<String>(
                                          value: option,
                                          toggleable: true,
                                          activeColor: AppColors.primary,
                                          title: Text(
                                            option,
                                            style: TextStyle(
                                              color: state.isReview
                                                  ? textColor
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ).padAll(5),
                                    );
                                  },
                                ),
                                10.hGap,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: ActionButton(
                                        backgroundColor: state.currentIndex == 0
                                            ? Colors.grey
                                            : AppColors.primary,
                                        text: "Previous",
                                        onTap: () {
                                          if (state.currentIndex > 0) {
                                            context
                                                .read<QuestionCubit>()
                                                .prevQuestion();
                                            scrollController.animateTo(
                                              0.0,
                                              duration: Duration(
                                                milliseconds: 500,
                                              ),
                                              curve: Curves.easeOut,
                                            );
                                          }
                                        },
                                        fontColor: Colors.white,
                                      ),
                                    ),
                                    20.wGap,
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 65.w),
                                        child: ActionButton(
                                          text:
                                              state.currentIndex <
                                                  state.questions.length - 1
                                              ? "Next"
                                              : "Finish",
                                          backgroundColor: state.isReview
                                              ? state.currentIndex <
                                                        state.questions.length -
                                                            1
                                                    ? AppColors.primary
                                                    : Colors.grey
                                              : AppColors.primary,
                                          onTap: () {
                                            if (state.currentIndex <
                                                state.questions.length - 1) {
                                              context
                                                  .read<QuestionCubit>()
                                                  .nextQuestion();
                                              scrollController.animateTo(
                                                0.0,
                                                duration: Duration(
                                                  milliseconds: 500,
                                                ),
                                                curve: Curves.easeOut,
                                              );
                                            } else {
                                              if (!state.isReview) {
                                                var time = totalTime(context);
                                                _buildSubmitDialog(
                                                  context,
                                                  state,
                                                  time,
                                                  marks,
                                                );
                                              } else {
                                                null;
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            20.hGap,
                            state.isReview
                                ? Container(
                                    padding: EdgeInsets.all(16.w),
                                    margin: EdgeInsets.symmetric(
                                      vertical: 20.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50.withValues(
                                        alpha: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: Colors.blue.shade100,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.lightbulb_outline,
                                              color: Colors.blue.shade700,
                                              size: 22.sp,
                                            ),
                                            8.wGap,
                                            Text(
                                              "Explanation",
                                              style: TextStyle(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade900,
                                              ),
                                            ),
                                          ],
                                        ),
                                        15.hGap,
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _infoBadge(
                                              Icons.subject,
                                              "Subject: ",
                                              subjects[state.currentIndex],
                                            ),
                                            8.hGap,
                                            _infoBadge(
                                              Icons.topic,
                                              "Topic: ",
                                              topics[state.currentIndex],
                                            ),
                                            8.hGap,
                                            Row(
                                              children: [
                                                _infoBadge(
                                                  Icons.speed,
                                                  "Level: ",
                                                  difficultyLevel[state
                                                          .currentIndex]
                                                      .level,
                                                ),
                                                8.wGap,
                                                state.timePerQuestion.length >
                                                        state.currentIndex
                                                    ? _infoBadge(
                                                        Icons.timer,
                                                        "Time: ",
                                                        "${state.timePerQuestion[state.currentIndex]}s",
                                                      )
                                                    : SizedBox.shrink(),
                                              ],
                                            ),
                                          ],
                                        ),
                                        20.hGap,
                                        Divider(color: Colors.blue.shade100),
                                        15.hGap,
                                        state
                                            .questions[state.currentIndex]
                                            .explanation
                                            .toQuestionWidget(),
                                      ],
                                    ),
                                  )
                                : SizedBox.shrink(),
                            20.hGap,
                            if (state.isReview) ...[
                              BlocBuilder<PieChartBloc, PieChartState>(
                                builder: (context, correctState) {
                                  if (correctState
                                      is PerformanceSummaryLoading) {
                                    return const CircularProgressIndicator();
                                  }
                                  if (correctState is PieChartResultFailure) {
                                    return Center(
                                      child: Text(correctState.message.message),
                                    );
                                  }
                                  if (correctState is PieChartResultSuccess &&
                                      state.currentIndex >= 0 &&
                                      state.currentIndex <
                                          state.questions.length) {
                                    final questionId = state
                                        .questionModel[state.currentIndex]
                                        .questionId;

                                    final isNotAttempted =
                                        isQuestionNotAttempted(
                                          correctState,
                                          questionId,
                                        );
                                    if (isNotAttempted) {
                                      return ElevatedContainer(
                                        child: Text(
                                          'Question is not attempted by anyone yet',
                                          style: AppTexts.heading.copyWith(
                                            fontSize: 15.sp,
                                          ),
                                        ),
                                      );
                                    }
                                    // ✅ Otherwise → show pie chart
                                    return Column(
                                      children: [
                                        _buildPieCharts(
                                          correctState,
                                          questionId,
                                        ),
                                        20.hGap,
                                        BlocBuilder<
                                          BarChartBloc,
                                          BarChartState
                                        >(
                                          builder: (context, barState) {
                                            if (barState
                                                is OptionMatrixLoading) {
                                              return const SizedBox.shrink(); // or skeleton
                                            }

                                            if (barState
                                                is OptionMatrixResultFailure) {
                                              return ElevatedContainer(
                                                child: Text(
                                                  'Unable to load option statistics',
                                                  style: AppTexts.heading
                                                      .copyWith(
                                                        fontSize: 14.sp,
                                                      ),
                                                ),
                                              );
                                            }

                                            if (barState
                                                is OptionMatrixSuccess) {
                                              final questionId = state
                                                  .questionModel[state
                                                      .currentIndex]
                                                  .questionId;

                                              return McqVerticalBarChart(
                                                questionId: questionId,
                                                optionStats:
                                                    barState.questionStats,
                                              );
                                            }

                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                            20.hGap,
                            TestModule(
                              title: "Question Navigator",
                              cards: [
                                10.hGap,
                                Wrap(
                                  spacing: 6.w,
                                  runSpacing: 6.h,
                                  children: visibleIndexes.map((index) {
                                    return QuestionNavigatorButton(
                                      text: '${index + 1}',
                                      backgroundColor:
                                          state.currentIndex == index
                                          ? Colors.grey
                                          : state.answeredStatus[index]
                                          ? state.isReview
                                                ? state.isCorrect![index] ==
                                                          false
                                                      ? Colors.red
                                                      : Colors.green
                                                : Colors.black
                                          : Colors.white,
                                      fontColor: state.currentIndex == index
                                          ? Colors.black
                                          : state.answeredStatus[index]
                                          ? Colors.white
                                          : Colors.black,
                                      borderColor: state.currentIndex == index
                                          ? Colors.grey
                                          : state.answeredStatus[index]
                                          ? state.isReview
                                                ? state.isCorrect![index] ==
                                                          false
                                                      ? Colors.red
                                                      : Colors.green
                                                : Colors.black
                                          : Colors.black,
                                      onTap: () {
                                        scrollController.animateTo(
                                          0.0,
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.easeOut,
                                        );
                                        context
                                            .read<QuestionCubit>()
                                            .jumpToQuestion(index);
                                      },
                                    );
                                  }).toList(),
                                ),
                                10.hGap,
                                QuestionIndicator(
                                  text: state.isReview
                                      ? "Correct"
                                      : "Attempted",
                                  borderColor: state.isReview
                                      ? Colors.green
                                      : Colors.black,
                                  fillColor: state.isReview
                                      ? Colors.green
                                      : Colors.black,
                                ),
                                state.isReview
                                    ? QuestionIndicator(
                                        text: "Incorrect",
                                        borderColor: Colors.red,
                                        fillColor: Colors.red,
                                      )
                                    : SizedBox.shrink(),
                                QuestionIndicator(
                                  text: "Not Attempted",
                                  fillColor: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ).padAll(AppPaddings.defaultPadding),
                      );
                    },
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  String formatRemainingTime({
    required int remainingMinutes,
    required int remainingSeconds,
  }) {
    final totalSeconds = (remainingMinutes * 60) + remainingSeconds;

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }

  Padding _buildWhenLoading() {
    return Padding(
      padding: EdgeInsets.all(AppPaddings.defaultPadding),
      child: Skeletonizer(
        enabled: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fake progress bar
            CustomProgressBar(
              titleText: "Question 1 of 10",
              value: 0.1,
              labelText: "0 Answered",
            ),
            20.hGap,
            // Question Title
            TestModule(
              title: "Question 1",
              cards: [
                // Fake question
                Text("This is a sample question text."),
                10.hGap,
                // Fake options
                RadioGroup<String>(
                  groupValue: "",
                  onChanged: (value) {},
                  child: Column(
                    children: List.generate(4, (index) {
                      return BorderedContainer(
                        padding: EdgeInsets.zero,
                        radius: BorderRadius.circular(10),
                        borderColor: AppColors.accentColor,
                        child: RadioListTile<String>(
                          value: 'Option $index',
                          title: Text("Option $index"),
                        ),
                      ).padAll(5);
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _buildSubmitDialog(
    BuildContext context,
    McqQuestionCubitLoaded state,
    int timeTaken,
    List<int> marks,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final total = state.questions.length;
        final attempted = state.answeredStatus.where((status) => status).length;
        return CustomAlertdialog(
          title: "Submit Test",
          mainContent: "You have attempted $attempted out of $total questions.",
          content: "Are you sure you want to submit the test?",
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Submit",
                style: AppTexts.title.copyWith(color: Colors.white),
              ),
              onPressed: () {
                context.pop(); // close dialog
                context.read<TimerBloc>().add(TimerStop());
              },
            ),
          ],
        );
      },
    );
  }

  void _buildAutoSubmitDialog(BuildContext context, TestCubitSubmitted state) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        final total = state.totalQuestions;
        final attempted = state.answeredStatus.where((status) => status).length;
        return CustomAlertdialog(
          title: "Time is over",
          mainContent: "You have attempted $attempted out of $total questions.",
          content:
              'Your time for this test has ended. Submitting your answers now and showing your results.',
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "View Result",
                style: AppTexts.title.copyWith(color: Colors.white),
              ),
              onPressed: () {
                context.pop(); // close dialog
                context.pushReplacement(
                  AppRoutes.resultScreen,
                  extra: ResultScreenArgs(
                    isFromTest: true,
                    testModal: widget.dailyTestModel,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPieCharts(PieChartResultSuccess state, int questionId) {
    final stats = state.correctnessCounts.firstWhere(
      (e) => e['question_id'] == questionId,
      orElse: () => {'correct_count': 0, 'incorrect_count': 0},
    );

    final attemptedStats = state.attemptedCounts.firstWhere(
      (e) => e.questionId == questionId,
    );

    return TestModule(
      title: "Performance Summary",
      cards: [
        Row(
          children: [
            Expanded(
              child: CustomPieChart(
                total: stats['correct_count'] + stats['incorrect_count'],
                itemOne: stats['correct_count'],
                itemTwo: stats['incorrect_count'],
                colorOne: Colors.green,
                colorTwo: Colors.red,
                labelOne: 'Correct',
                labelTwo: 'Incorrect',
              ),
            ),
            10.wGap,
            Expanded(
              child: CustomPieChart(
                total: attemptedStats.totalUsers,
                itemOne: attemptedStats.attemptedCount,
                itemTwo: attemptedStats.notAttemptedCount,
                colorOne: Colors.blue,
                colorTwo: Colors.grey,
                labelOne: 'Attempted',
                labelTwo: 'Not Attempted',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper method to identify Prelims test
  bool _isPrelimsTest() {
    return widget.dailyTestModel.testType == TestType.prelims;
  }

  // Handle test pause
  Future<void> _handlePause(BuildContext context) async {
    final timerBloc = context.read<TimerBloc>();
    final questionCubit = context.read<QuestionCubit>();
    final userId = getIt<CacheManager>().getUserId();

    final remainingTime = timerBloc.getRemainingSeconds();

    await questionCubit.savePrelimsProgress(
      userId: userId,
      testId: widget.dailyTestModel.id,
      languageCode: widget.language!,
      remainingTimeInSeconds: remainingTime,
    );

    if (_isPrelimsTest()) {
      await getIt<TestRepository>().updateUserTestStatus(
        testId: widget.dailyTestModel.id,
        status: 'paused',
      );
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Test Paused"),
        content: const Text(
          "Progress saved. Resume from the test list.\n\n"
          "Note: Progress expires in 24 hours.",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.blue.shade700),
          6.wGap,
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

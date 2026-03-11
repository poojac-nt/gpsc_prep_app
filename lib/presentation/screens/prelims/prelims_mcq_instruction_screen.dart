import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/data/repositories/prelims_progress_repository.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/prelims_test_progress.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';
import 'package:gpsc_prep_app/domain/usecases/get_available_language_usecase.dart';
import 'package:gpsc_prep_app/presentation/blocs/daily_test/daily_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/download%20pdf/download_pdf_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/fetch_single_test/fetch_single_test_bloc.dart';
import 'package:gpsc_prep_app/utils/extensions/hour_extension.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import '../../../utils/app_constants.dart';
import '../../../utils/enums/user_role.dart';
import '../../widgets/action_button.dart';
import '../../widgets/test_status_dialog.dart';

class PrelimsMcqInstructionScreen extends StatefulWidget {
  const PrelimsMcqInstructionScreen({super.key, this.testModel, this.testId});

  final TestModel? testModel;
  final int? testId;

  @override
  State<PrelimsMcqInstructionScreen> createState() =>
      _PrelimsMcqInstructionScreenState();
}

class _PrelimsMcqInstructionScreenState
    extends State<PrelimsMcqInstructionScreen> {
  String selectedLanguage = 'en';
  late Set<String> availableLanguagesButton = {'en'};
  TestModel? _fetchedTestModel;
  late bool isFromId;
  bool _noTestDetected = false;
  bool _hasProgress = false;

  final Map<String, String> _languageLabels = {
    'en': 'English',
    'hi': 'Hindi',
    'gj': 'Gujarati',
  };

  @override
  void initState() {
    super.initState();
    isFromId = widget.testId != null;
    if (isFromId) {
      context.read<FetchSingleTestBloc>().add(
        FetchSingleTestFromId(widget.testId!),
      );
    }
    _checkProgress();
    fetchAvailableLanguages();
    selectedLanguage =
        availableLanguagesButton.contains('en')
            ? 'en'
            : availableLanguagesButton.first;
  }

  Future<void> fetchAvailableLanguages() async {
    final getLanguages = GetAvailableLanguagesForTestUseCase(
      getIt<TestRepository>(),
    );
    var availableLanguages = await getLanguages(
      widget.testId ?? widget.testModel!.id,
    );
    setState(() {
      availableLanguagesButton = availableLanguages;
    });
  }

  Future<void> _checkProgress() async {
    final testId = widget.testId ?? widget.testModel?.id;
    if (testId == null) return;

    final progressRepo = getIt<PrelimsProgressRepository>();
    final userId = getIt<CacheManager>().getUserId();
    final savedProgress = progressRepo.getProgress(userId, testId);

    if (savedProgress != null && !savedProgress.isExpired()) {
      setState(() => _hasProgress = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FetchSingleTestBloc, FetchSingleTestState>(
      listener: (context, state) {
        if (state is SingleTestFetched) {
          setState(() => _fetchedTestModel = state.dailyTestModel);
        } else if (state is SingleTestFetchingFailed) {
          setState(() => _noTestDetected = true);
        }
      },
      child: BlocBuilder<DailyTestBloc, DailyTestState>(
        builder: (context, state) {
          if (_noTestDetected) return _buildNoTestScreen(context);
          if (state is FetchSingleTestState || state is SingleTestFetching) {
            return _loadingScreen();
          }

          final testModel = widget.testModel ?? _fetchedTestModel;
          if (testModel != null) {
            return buildScaffoldWithModel(context, testModel);
          }

          return _loadingScreen();
        },
      ),
    );
  }

  Widget _loadingScreen() =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));

  Widget _buildNoTestScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This test does not exist.',
              style: TextStyle(fontSize: 18),
            ),
            16.hGap,
            ElevatedButton(
              onPressed: () {
                final role = getIt<CacheManager>().getUserRole();
                if (role == UserRole.admin) {
                  context.go(AppRoutes.adminDashboard);
                } else if (role == UserRole.mentor) {
                  context.go(AppRoutes.mentorDashboard);
                } else {
                  context.go(AppRoutes.studentDashboard);
                }
              },
              child: const Text('Go back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildScaffoldWithModel(BuildContext context, TestModel testModel) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xfff7f8f9),
        appBar: AppBar(
          leading: IconButton(
            onPressed: _handleBackNavigation,
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(testModel.name, style: AppTexts.titleTextStyle),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: BlocListener<DownLoadPdfBloc, DownLoadPdfState>(
          listener: (context, state) {
            if (state is PdfDownloadFailure) {
              getIt<SnackBarHelper>().showError(
                'Download failed: ${state.failure.message}',
              );
            } else if (state is PdfDownloadSuccess) {
              getIt<SnackBarHelper>().showSuccess(
                'Download completed successfully!',
              );
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: InfoTile(
                        value: testModel.noQuestions.toString(),
                        label: "QUESTIONS",
                        icon: Icons.quiz_rounded,
                      ),
                    ),
                    15.wGap,
                    Expanded(
                      child: InfoTile(
                        value: testModel.duration.toString(),
                        label: "MINUTES",
                        icon: Icons.access_time,
                      ),
                    ),
                  ],
                ),
                20.hGap,

                // Instructions Card
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        offset: const Offset(0, 4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Test Instructions:",
                        style: AppTexts.labelTextStyle,
                      ),
                      15.hGap,
                      _buildInstructionTile(
                        "This test contains ${testModel.noQuestions} multiple choice questions.",
                        Icons.check_circle_rounded,
                        AppColors.primary,
                      ),
                      _buildInstructionTile(
                        "There is a penalty of 0.33 marks for each incorrect response.",
                        Icons.error_outline_rounded,
                        Colors.red,
                      ),
                      _buildInstructionTile(
                        "You can navigate between questions using next/previous buttons.",
                        Icons.compare_arrows_rounded,
                        Colors.blue,
                      ),
                      _buildInstructionTile(
                        "Click to Submit to finish test and generate your result.",
                        Icons.flag_rounded,
                        Colors.blue,
                      ),
                    ],
                  ),
                ),
                20.hGap,

                // Language Selection
                Text("Choose Language", style: AppTexts.labelTextStyle),
                10.hGap,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                      availableLanguagesButton
                          .where((code) => _languageLabels.containsKey(code))
                          .map(
                            (code) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
                                child: _languageButton(code),
                              ),
                            ),
                          )
                          .toList(),
                ),
                20.hGap,

                // Start Test
                ActionButton(
                  text: _hasProgress ? "Resume Test" : "Start Test",
                  onTap: () => _handleTestStart(testModel),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  backgroundColor: AppColors.primary,
                ),
                15.hGap,

                // Secondary Actions
                Row(
                  children: [
                    Expanded(
                      child: _buildOutlinedButton(
                        "Download",
                        Icons.download,
                        () {
                          context.read<DownLoadPdfBloc>().add(
                            DownloadPrelimsOmr(
                              url: testModel.omrLink ?? '',
                              filename:
                                  'OMR_${testModel.name.replaceAll(' ', '_')}',
                            ),
                          );
                        },
                      ),
                    ),
                    15.wGap,
                    Expanded(
                      child: _buildOutlinedButton(
                        "Submit OMR",
                        color: _hasProgress ? Colors.grey : Colors.black87,
                        Icons.upload_file,
                        () {
                          context.pushReplacement(
                            AppRoutes.omrScreen,
                            extra: OMRScreenArgs(
                              testModal: testModel,
                              language: selectedLanguage,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                30.hGap,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleBackNavigation() {
    if (widget.testId != null) {
      context.pop();
      debugPrint("Test Id is Null");
    } else {
      debugPrint("Going Back");
      context.pop();
    }
  }

  Widget _buildInstructionTile(String text, IconData icon, Color iconColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: iconColor),
          12.wGap,
          Expanded(
            child: Text(
              text,
              style: AppTexts.subTitle.copyWith(
                color: Colors.grey[700],
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageButton(String code) {
    final bool isSelected = selectedLanguage == code;
    return InkWell(
      onTap: () => setState(() => selectedLanguage = code),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F1FF) : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected) ...[
              Icon(Icons.language, size: 16.sp, color: AppColors.primary),
              8.wGap,
            ],
            Text(
              _languageLabels[code]!,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(
    String text,
    IconData icon,
    VoidCallback onTap, {
    Color color = Colors.black87,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18.sp, color: color),
          8.wGap,
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleTestStart(TestModel dailyTestModel) async {
    final progressRepo = getIt<PrelimsProgressRepository>();
    final userId = getIt<CacheManager>().getUserId();

    // Check for saved progress FIRST
    final savedProgress = progressRepo.getProgress(userId, dailyTestModel.id);
    if (savedProgress != null && !savedProgress.isExpired()) {
      _showResumeDialog(dailyTestModel, savedProgress);
      return;
    }

    // Then check for completed result
    final supabaseHelper = getIt<SupabaseHelper>();
    try {
      final testResult = await supabaseHelper.fetchResultForSingleMcqTest(
        testId: dailyTestModel.id,
      );
      final result = testResult.right;
      if (result == null) {
        _startTest(dailyTestModel);
        return;
      }
      final isEligibleForRetest = _checkRetestEligibility(result.createdAt);
      if (isEligibleForRetest) {
        _startTest(dailyTestModel);
      } else {
        bool isLimitReached = result.attemptNo! >= 2;
        showAlreadyGivenTestDialog(result, isLimitReached: isLimitReached);
      }
    } catch (error) {
      getIt<LogHelper>().e("Error fetching test result: $error");
    }
  }

  void showAlreadyGivenTestDialog(
    TestResultModel testResult, {
    required bool isLimitReached,
  }) {
    String createdAtStr = testResult.createdAt!;
    String formattedDate = createdAtStr.toFormattedDate();

    int hoursRemaining = createdAtStr.hoursRemaining(12);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TestStatusDialog(
          title: isLimitReached ? "Attempts Completed" : "Test Cooldown",
          message:
              isLimitReached
                  ? "You have completed both of your attempts for this test."
                  : "You have already attempted this test once.",
          lastAttemptDate: formattedDate,
          hoursRemaining: isLimitReached ? null : hoursRemaining,
          isLimitReached: isLimitReached,
        );
      },
    );
  }

  void _startTest(TestModel dailyTestModel) {
    context.pushReplacement(
      AppRoutes.testScreen,
      extra: TestScreenArgs(
        isFromResult: false,
        language: selectedLanguage,
        testModal: dailyTestModel,
        hasPrelimsProgress: false, // Starting fresh
      ),
    );
  }

  void _showResumeDialog(TestModel test, PrelimsTestProgress progress) {
    final answered = progress.answeredStatus.where((a) => a).length;
    final mins = progress.remainingTimeInSeconds ~/ 60;
    final secs = progress.remainingTimeInSeconds % 60;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text("Resume Test?"),
            content: Text(
              "You have an incomplete test:\n\n"
              "• Answered: $answered/${progress.totalQuestions}\n"
              "• Question: ${progress.currentQuestionIndex + 1}\n"
              "• Time left: ${mins}m ${secs}s\n\n"
              "Resume or start fresh?",
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final userId = getIt<CacheManager>().getUserId();
                  await getIt<PrelimsProgressRepository>().deleteProgress(
                    userId,
                    test.id,
                  );
                  await getIt<TestRepository>().deleteUserTest(testId: test.id);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _startTest(test);
                },
                child: const Text("Start Fresh"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _resumeTest(test, progress);
                },
                child: const Text(
                  "Resume",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _resumeTest(TestModel test, PrelimsTestProgress progress) {
    context.pushReplacement(
      AppRoutes.testScreen,
      extra: TestScreenArgs(
        isFromResult: false,
        language: progress.languageCode,
        testModal: test,
        hasPrelimsProgress: true, // Resuming from progress
      ),
    );
  }

  bool _checkRetestEligibility(String? createdAtString) {
    if (createdAtString == null || createdAtString.isEmpty) return true;
    try {
      final submittedAt = DateTime.parse(createdAtString);
      return DateTime.now().difference(submittedAt).inHours >= 12;
    } catch (_) {
      return true;
    }
  }
}

class InfoTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const InfoTile({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 7.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            offset: const Offset(0, 4),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF88ABEE), size: 24.sp),
          10.hGap,
          Text(
            value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          4.hGap,
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[400],
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

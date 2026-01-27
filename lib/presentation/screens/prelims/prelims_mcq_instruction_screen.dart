import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/data/repositories/prelims_progress_repository.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/prelims_test_progress.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';
import 'package:gpsc_prep_app/domain/usecases/get_available_language_usecase.dart';
import 'package:gpsc_prep_app/presentation/blocs/daily_test/daily_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/daily_test/daily_test_state.dart';
import 'package:gpsc_prep_app/presentation/blocs/fetch_single_test/fetch_single_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/fetch_single_test/fetch_single_test_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/fetch_single_test/fetch_single_test_state.dart';
import 'package:gpsc_prep_app/utils/extensions/hour_extension.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:intl/intl.dart';

import '../../../utils/app_constants.dart';
import '../../widgets/action_button.dart';

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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.studentDashboard),
              child: const Text('Go back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildScaffoldWithModel(
    BuildContext context,
    TestModel dailyTestModel,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f8f9),
      appBar: AppBar(
        leading: IconButton(
          onPressed: _handleBackNavigation,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(dailyTestModel.name, style: AppTexts.titleTextStyle),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: InfoTile(
                    value: dailyTestModel.noQuestions.toString(),
                    label: "QUESTIONS",
                    icon: Icons.quiz_rounded,
                  ),
                ),
                15.wGap,
                Expanded(
                  child: InfoTile(
                    value: dailyTestModel.duration.toString(),
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
                  Text("Test Instructions:", style: AppTexts.labelTextStyle),
                  15.hGap,
                  _buildInstructionTile(
                    "This test contains ${dailyTestModel.noQuestions} multiple choice questions.",
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
              children:
                  availableLanguagesButton
                      .where((code) => _languageLabels.containsKey(code))
                      .map(
                        (code) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: _languageButton(code),
                          ),
                        ),
                      )
                      .toList(),
            ),
            25.hGap,

            // Start Test
            ActionButton(
              text: "Start Test",
              onTap: () => _handleTestStart(dailyTestModel),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              backgroundColor: AppColors.primary,
            ),
            15.hGap,

            // Secondary Actions
            Row(
              children: [
                Expanded(
                  child: _buildOutlinedButton("Download", Icons.download, () {
                    context.push(AppRoutes.omrScreen);
                  }),
                ),
                15.wGap,
                Expanded(
                  child: _buildOutlinedButton(
                    "Submit OMR",
                    Icons.upload_file,
                    () {},
                  ),
                ),
              ],
            ),
            30.hGap,
          ],
        ),
      ),
    );
  }

  void _handleBackNavigation() {
    if (widget.testId != null) {
      context.pop();
      debugPrint("Test Id is Null");
    } else {
      debugPrint("Going to Dashboard");
      context.pushReplacement(AppRoutes.studentDashboard);
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

  Widget _buildOutlinedButton(String text, IconData icon, VoidCallback onTap) {
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
          Icon(icon, size: 18.sp, color: Colors.black87),
          8.wGap,
          Text(
            text,
            style: TextStyle(
              color: Colors.black87,
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
        showAlreadyGivenTestDialog(result);
      }
    } catch (error) {
      getIt<LogHelper>().e("Error fetching test result: $error");
    }
  }

  void showAlreadyGivenTestDialog(TestResultModel testResult) {
    String createdAtStr = testResult.createdAt!;
    String formattedDate = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(createdAtStr.toLocalDateTime());

    int hoursPassed = createdAtStr.hoursPassedSince();
    int hoursRemaining = createdAtStr.hoursRemaining(12);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Test Status"),
          content: Text(
            "You have already given the test.\n\n"
            "Last attempt: $formattedDate\n"
            "Hours passed: $hoursPassed\n"
            "You can attempt again in $hoursRemaining hour(s).",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
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
                  await getIt<PrelimsProgressRepository>().deleteProgress(
                    getIt<CacheManager>().getUserId(),
                    test.id,
                  );
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

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
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/extensions/hour_extension.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:intl/intl.dart';

import '../../../utils/app_constants.dart';
import '../../widgets/action_button.dart';

class PrelimsMcqInstructionScreen extends StatefulWidget {
  const PrelimsMcqInstructionScreen({
    super.key,
    this.dailyTestModel,
    this.testId,
  });

  final TestModel? dailyTestModel;
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

  final List<String> _instructions = [
    "This test contains {questions} multiple choice questions",
    "There is a penalty of 0.33 marks for each incorrect response",
    "You can navigate between questions using next/previous buttons",
    "Click to Submit to finish test",
  ];

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
      widget.testId ?? widget.dailyTestModel!.id,
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

          final testModel = widget.dailyTestModel ?? _fetchedTestModel;
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
      appBar: AppBar(
        leading: IconButton(
          onPressed: _handleBackNavigation,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(dailyTestModel.name, style: AppTexts.titleTextStyle),
      ),
      body: SingleChildScrollView(
        child: TestModule(
          title: "Test Instructions",
          prefixIcon: Icons.menu_book_outlined,
          cards: [
            InfoTile(
              value: dailyTestModel.noQuestions.toString(),
              label: "Questions",
            ),
            10.hGap,
            InfoTile(
              value: dailyTestModel.duration.toString(),
              label: "Minutes",
            ),
            10.hGap,
            Text("Instructions: ", style: AppTexts.labelTextStyle),
            10.hGap,
            ..._instructions.map(
              (text) => _buildInstructionTile(
                text.replaceAll(
                  "{questions}",
                  dailyTestModel.noQuestions.toString(),
                ),
              ),
            ),
            15.hGap,
            Text("Choose Language", style: AppTexts.labelTextStyle),
            10.hGap,
            Wrap(
              spacing: 8,
              children:
                  availableLanguagesButton
                      .where((code) => _languageLabels.containsKey(code))
                      .map((code) => _languageButton(code))
                      .toList(),
            ),
            15.hGap,
            ActionButton(
              text: "Start Test",
              onTap: () => _handleTestStart(dailyTestModel),
            ),
          ],
        ).padAll(AppPaddings.defaultPadding),
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

  Widget _buildInstructionTile(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Icon(Icons.circle, size: 6.sp),
          ),
          10.wGap,
          Expanded(
            child: Text(
              text,
              maxLines: 3,
              overflow: TextOverflow.visible,
              style: AppTexts.subTitle.copyWith(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageButton(String code) {
    final bool isSelected = selectedLanguage == code;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue.shade100 : null,
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey,
          width: 2,
        ),
      ),
      onPressed: () => setState(() => selectedLanguage = code),
      child: Text(
        _languageLabels[code]!,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
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

  const InfoTile({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return BorderedContainer(
      padding: EdgeInsets.all(AppPaddings.defaultPadding),
      radius: BorderRadius.zero,
      child: Center(
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            Text(label, style: AppTexts.subTitle.copyWith(fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }
}

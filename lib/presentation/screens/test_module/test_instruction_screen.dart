import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/daily_test_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:gpsc_prep_app/domain/usecases/get_available_language_usecase.dart';
import 'package:gpsc_prep_app/presentation/blocs/daily%20test/daily_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/daily%20test/daily_test_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/daily%20test/daily_test_state.dart';
import 'package:gpsc_prep_app/presentation/widgets/bordered_container.dart';
import 'package:gpsc_prep_app/presentation/widgets/test_module.dart';
import 'package:gpsc_prep_app/utils/extensions/hour_extension.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:intl/intl.dart';

import '../../../utils/app_constants.dart';
import '../../widgets/action_button.dart';

class TestInstructionScreen extends StatefulWidget {
  const TestInstructionScreen({super.key, this.dailyTestModel, this.testId});

  final DailyTestModel? dailyTestModel;
  final int? testId;

  @override
  State<TestInstructionScreen> createState() => _TestInstructionScreenState();
}

class _TestInstructionScreenState extends State<TestInstructionScreen> {
  String selectedLanguage = 'en';
  late Set<String> availableLanguagesButton = {'en'};
  DailyTestModel? _fetchedTestModel;

  @override
  void initState() {
    super.initState();
    fetchAvailableLanguages();
    selectedLanguage =
        availableLanguagesButton.contains('en')
            ? 'en'
            : availableLanguagesButton.first;
    if (widget.dailyTestModel == null) {
      context.read<DailyTestBloc>().add(FetchSingleTestFromId(widget.testId!));
    }
  }

  Future<void> fetchAvailableLanguages() async {
    final getLanguages = GetAvailableLanguagesForTestUseCase(
      getIt<TestRepository>(),
    );
    var availableLanguages = await getLanguages(widget.dailyTestModel!.id);
    setState(() {
      availableLanguagesButton = availableLanguages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DailyTestBloc, DailyTestState>(
      builder: (context, state) {
        if (state is SingleTestFetching) {
          return Center(child: CircularProgressIndicator());
        }
        if (state is SingleTestFetchingFailed) {
          return Center(child: Text(state.failure.message));
        }
        if (state is SingleTestFetched) {
          _fetchedTestModel = state.dailyTestModel;
        }
        final DailyTestModel? testModel =
            widget.dailyTestModel ?? _fetchedTestModel;

        if (testModel != null) {
          return buildScaffoldWithModel(context, testModel);
        }

        return Center(child: Text('No data'));
      },
    );
  }

  Widget buildScaffoldWithModel(
    BuildContext context,
    DailyTestModel dailyTestModel,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dailyTestModel.name, style: AppTexts.titleTextStyle),
      ),
      body: SingleChildScrollView(
        child: TestModule(
          title: "Test Instructions",
          prefixIcon: Icons.menu_book_outlined,
          cards: [
            BorderedContainer(
              padding: EdgeInsets.all(AppPaddings.defaultPadding),
              radius: BorderRadius.zero,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      dailyTestModel.noQuestions.toString(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Questions",
                      style: AppTexts.subTitle.copyWith(fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
            ),
            10.hGap,
            BorderedContainer(
              padding: EdgeInsets.all(AppPaddings.defaultPadding),
              radius: BorderRadius.zero,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      dailyTestModel.duration.toString(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Minutes",
                      style: AppTexts.subTitle.copyWith(fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
            ),
            // 10.hGap,
            // BorderedContainer(
            //   padding: EdgeInsets.all(AppPaddings.defaultPadding),
            //   radius: BorderRadius.zero,
            //   child: Center(
            //     child: Column(
            //       children: [
            //         Text(
            //           "1",
            //           style: TextStyle(
            //             fontSize: 20.sp,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //         Text("Mark Each", style: AppTexts.subTitle),
            //       ],
            //     ),
            //   ),
            // ),
            10.hGap,
            Text("Instructions: ", style: AppTexts.labelTextStyle),
            10.hGap,
            _buildInstructionTile(
              "This test contains ${dailyTestModel.noQuestions} multiple choice questions",
            ),
            3.hGap,
            _buildInstructionTile(
              "There is a penalty of 0.33 marks for each incorrect response",
            ),
            3.hGap,
            _buildInstructionTile(
              "You can navigate between questions using next/previous buttons",
            ),
            3.hGap,
            _buildInstructionTile("Click to Submit to finish test"),
            15.hGap,
            10.hGap,
            Text("Choose Language", style: AppTexts.labelTextStyle),
            10.hGap,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (availableLanguagesButton.contains('en'))
                  _languageButton(context, 'English', 'en'),
                if (availableLanguagesButton.contains('hi'))
                  _languageButton(context, 'Hindi', 'hi'),
                if (availableLanguagesButton.contains('gj'))
                  _languageButton(context, 'Gujarati', 'gj'),
              ],
            ),
            15.hGap,
            ActionButton(
              text: "Start Test",
              onTap: () async {
                final supabaseHelper = getIt<SupabaseHelper>();
                try {
                  final testResult = await supabaseHelper
                      .fetchResultForSingleMcqTest(testId: dailyTestModel.id);
                  final result = testResult.right;
                  if (result == null) {
                    _startTest(context, dailyTestModel);
                    return;
                  }
                  final isEligibleForRetest = _checkRetestEligibility(
                    result.createdAt,
                  );
                  if (isEligibleForRetest) {
                    _startTest(context, dailyTestModel);
                  } else {
                    showAlreadyGivenTestDialog(context, result);
                  }
                } catch (error) {
                  getIt<LogHelper>().e("Error fetching test result: $error");
                }
              },
            ),
          ],
        ).padAll(AppPaddings.defaultPadding),
      ),
    );
  }

  Widget _buildInstructionTile(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 6.h),
          child: Icon(Icons.circle, size: 6.sp),
        ),
        10.wGap,
        Expanded(
          child: Text(
            maxLines: 3,
            overflow: TextOverflow.visible,
            text,
            style: AppTexts.subTitle.copyWith(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _languageButton(BuildContext context, String label, String code) {
    final bool isSelected = selectedLanguage == code;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue.shade100 : null,
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey,
          width: 2,
        ),
      ),
      onPressed: () {
        setState(() {
          selectedLanguage = code;
        });
      },
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  void showAlreadyGivenTestDialog(
    BuildContext context,
    TestResultModel testResult,
  ) {
    String createdAtStr = testResult.createdAt!;

    // Format date
    String formattedDate = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(createdAtStr.toLocalDateTime());

    // Use extension methods
    int hoursPassed = createdAtStr.hoursPassedSince();
    int hoursRemaining = createdAtStr.hoursRemaining(12);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Test Status"),
          content: Text(
            "You have already given the test.\n\n"
            "Last attempt: $formattedDate\n"
            "Hours passed: $hoursPassed\n"
            "You can attempt again in $hoursRemaining hour(s).",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _startTest(BuildContext context, DailyTestModel dailyTestModel) {
    context.pushReplacement(
      AppRoutes.testScreen,
      extra: TestScreenArgs(
        isFromResult: false,
        language: selectedLanguage,
        dailyTestModel: dailyTestModel,
      ),
    );
  }

  bool _checkRetestEligibility(String? createdAtString) {
    if (createdAtString == null || createdAtString.isEmpty) return true;
    try {
      final submittedAt = DateTime.parse(createdAtString);
      return DateTime.now().difference(submittedAt).inHours >= 12;
    } catch (_) {
      return true; // If parsing fails, allow retest by default
    }
  }
}

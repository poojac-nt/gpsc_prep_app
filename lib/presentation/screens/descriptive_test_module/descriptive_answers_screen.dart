import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/presentation/blocs/download%20pdf/download_pdf_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/question/question_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/desc_question_tile.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DescriptiveAnswersScreen extends StatefulWidget {
  final DescriptiveAnswersScreenArgs args;

  const DescriptiveAnswersScreen({super.key, required this.args});

  @override
  State<DescriptiveAnswersScreen> createState() =>
      _DescriptiveAnswersScreenState();
}

class _DescriptiveAnswersScreenState extends State<DescriptiveAnswersScreen> {
  late String _selectedLanguage;

  /// The languages allowed for this test, normalised to lowercase.
  List<String> get _allowedLanguages =>
      widget.args.languages.map((e) => e.toLowerCase()).toList();

  @override
  void initState() {
    super.initState();
    // Default to the first allowed language (or 'en' if the list is empty).
    _selectedLanguage = _allowedLanguages.isNotEmpty
        ? _allowedLanguages.first
        : 'en';
    _loadQuestions(_selectedLanguage);
  }

  void _loadQuestions(String language) {
    context.read<QuestionBloc>().add(
      LoadDescQuestion(widget.args.descTestModel.id, language),
    );
  }

  /// Cycles to the next allowed language and reloads questions.
  void _switchLanguage() {
    final langs = _allowedLanguages;
    if (langs.length <= 1) return;
    final nextIndex = (langs.indexOf(_selectedLanguage) + 1) % langs.length;
    setState(() => _selectedLanguage = langs[nextIndex]);
    _loadQuestions(_selectedLanguage);
  }

  /// Returns the display character for the AppBar language button.
  String _langChar(String lang) {
    switch (lang) {
      case 'hi':
        return 'अ';
      case 'gj':
        return 'અ';
      case 'en':
      default:
        return 'A';
    }
  }

  /// Resolves the question text for the currently selected language,
  /// falling back to English if the translation is missing.
  String _resolveQuestionText(dynamic question) {
    switch (_selectedLanguage) {
      case 'hi':
        return question.questionHi?.questionTxt ??
            question.questionEn.questionTxt;
      case 'gj':
        return question.questionGj?.questionTxt ??
            question.questionEn.questionTxt;
      case 'en':
      default:
        return question.questionEn.questionTxt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.args.showPeerReview ? 'Peer Review' : 'Model Answers',
          style: AppTexts.titleTextStyle,
        ),
        centerTitle: true,
        actions: [
          // Show the toggle button only when multiple languages are available.
          if (_allowedLanguages.length > 1)
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: TextButton(
                onPressed: _switchLanguage,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _langChar(_selectedLanguage),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.swap_horiz_rounded,
                      size: 16.sp,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          IconButton(
            onPressed: () async {
              final result = await getIt<TestRepository>()
                  .fetchDescTestQuestions(widget.args.descTestModel.id);
              result.fold(
                (failure) => getIt<SnackBarHelper>().showError(failure.message),
                (questions) {
                  getIt<DownLoadPdfBloc>().add(
                    DownloadFullDescTestPdf(
                      questions: questions,
                      testName: widget.args.descTestModel.name,
                      langCodes: widget.args.languages,
                      showAnswers: true,
                    ),
                  );
                },
              );
            },
            icon: Icon(Icons.arrow_circle_down, color: AppColors.primary),
          ),
        ],
      ),
      body: BlocBuilder<QuestionBloc, QuestionState>(
        builder: (context, state) {
          if (state is QuestionLoading) {
            return _buildWhenLoading();
          } else if (state is DescQuestionLoaded) {
            final questions = state.questionsModels;
            return ListView.separated(
              padding: EdgeInsets.all(AppPaddings.defaultPadding),
              itemCount: questions.length,
              separatorBuilder: (context, index) => 12.hGap,
              itemBuilder: (context, index) {
                final question = questions[index];
                return QuestionTile(
                  index: index,
                  questionText: _resolveQuestionText(question),
                  onTap: () {
                    context.push(
                      AppRoutes.descAnswerDetail,
                      extra: DescriptiveAnswerDetailScreenArgs(
                        question: question,
                        index: index,
                        // Pass only the allowed languages so the detail screen
                        // also restricts its toggle to the same set.
                        language:
                            widget.args.descTestModel.allowedLanguages ?? [],
                        testId: widget.args.descTestModel.id,
                        isUnlocked: widget.args.isUnlocked,
                        showPeerReview: widget.args.showPeerReview,
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is QuestionLoadFailed) {
            return Center(
              child: Text('Failed to load questions: ${state.failure.message}'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildWhenLoading() {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: EdgeInsets.all(AppPaddings.defaultPadding),
        itemCount: 5,
        separatorBuilder: (context, index) => 12.hGap,
        itemBuilder: (context, index) => Container(
          height: 80.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: AppBorders.borderRadius,
          ),
        ),
      ),
    );
  }
}

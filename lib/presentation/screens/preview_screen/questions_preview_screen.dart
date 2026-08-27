import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/domain/entities/result_with_top_score_model.dart';
import 'package:gpsc_prep_app/domain/entities/test_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/download%20pdf/download_pdf_bloc.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/services/test_link_generator.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../../../domain/entities/detailed_test_result_model.dart';
import '../../../utils/extensions/padding.dart';

class QuestionPreviewScreen extends StatefulWidget {
  const QuestionPreviewScreen({
    super.key,
    required this.questions,
    required this.testName,
    this.performanceSummary,
    this.testModel,
    this.detailedResults,
  });

  final List<QuestionModel> questions;
  final String testName;
  final TestResultWithTopScoreModel? performanceSummary;
  final TestModel? testModel;
  final List<DetailedTestResult>? detailedResults;

  @override
  State<QuestionPreviewScreen> createState() => _QuestionPreviewScreenState();
}

class _QuestionPreviewScreenState extends State<QuestionPreviewScreen> {
  late String _selectedLanguage;
  late List<String> _availableLanguages;

  @override
  void initState() {
    super.initState();
    // Restrict to test's allowedLanguages; fall back to English-only.
    _availableLanguages =
        (widget.testModel?.allowedLanguages ?? [])
            .map((e) => e.toLowerCase())
            .where((e) => ['en', 'hi', 'gj'].contains(e))
            .toList();
    if (_availableLanguages.isEmpty) _availableLanguages = ['en'];

    // Default to the first allowed language.
    _selectedLanguage = _availableLanguages.first;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  QuestionLanguageData _getLangData(QuestionModel q) {
    switch (_selectedLanguage) {
      case 'hi':
        return q.questionHi ?? q.questionEn;
      case 'gj':
        return q.questionGj ?? q.questionEn;
      case 'en':
      default:
        return q.questionEn;
    }
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'hi':
        return 'हिंदी';
      case 'gj':
        return 'ગુજ';
      case 'en':
      default:
        return 'Eng';
    }
  }

  String _languageChar(String code) {
    switch (code) {
      case 'hi':
        return 'अ';
      case 'gj':
        return 'અ';
      case 'en':
      default:
        return 'A';
    }
  }

  // ── Language picker bottom-sheet ───────────────────────────────────────────

  void _showLanguagePicker({required VoidCallback onSelected}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              ..._availableLanguages.map((lang) {
                final isSelected = lang == _selectedLanguage;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isSelected ? AppColors.primary : Colors.grey.shade200,
                    child: Text(
                      _languageChar(lang),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    _languageLabel(lang),
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing:
                      isSelected
                          ? Icon(Icons.check, color: AppColors.primary)
                          : null,
                  onTap: () {
                    setState(() => _selectedLanguage = lang);
                    Navigator.pop(ctx);
                    onSelected();
                  },
                );
              }),
              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );
  }

  // ── Export ─────────────────────────────────────────────────────────────────

  void _exportPdf() {
    if (widget.questions.isEmpty) return;
    context.read<DownLoadPdfBloc>().add(
      ExportQuestionsToPdfEvent(
        widget.questions,
        widget.testName,
        performanceSummary: widget.performanceSummary,
        testType: widget.testModel?.testType,
        detailedResults: widget.detailedResults,
        language: _selectedLanguage,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Preview Questions', style: AppTexts.titleTextStyle),
        ),
        body: const Center(child: Text('No questions available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Preview Questions', style: AppTexts.titleTextStyle),
        actions: [
          // Language toggle — only visible when multiple languages are allowed.
          if (_availableLanguages.length > 1)
            IconButton(
              tooltip:
                  'Language: ${_languageLabel(_selectedLanguage)}\nTap to switch',
              onPressed: () => _showLanguagePicker(onSelected: () {}),
              icon: Text(
                _languageChar(_selectedLanguage),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: BlocListener<DownLoadPdfBloc, DownLoadPdfState>(
        listener: (context, state) {
          if (state is PdfDownloadSuccess) {
            getIt<SnackBarHelper>().showSuccess("PDF Downloaded Successfully");
          }
          if (state is PdfDownloadFailure) {
            getIt<SnackBarHelper>().showError(state.failure.message);
          }
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount:
              widget.questions.length +
              (widget.testModel?.testType == TestType.prelims &&
                      widget.performanceSummary != null
                  ? 1
                  : 0),
          itemBuilder: (context, index) {
            if (widget.testModel?.testType == TestType.prelims &&
                widget.performanceSummary != null) {
              if (index == 0) return _buildPerformanceSummary();
              index--;
            }
            final q = _getLangData(widget.questions[index]);
            return _buildQuestionCard(q, index);
          },
        ),
      ),
      floatingActionButton: BlocBuilder<DownLoadPdfBloc, DownLoadPdfState>(
        builder: (context, pdfState) {
          final isLoading = pdfState is DownLoadPdfStarted;
          return FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            icon:
                isLoading
                    ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Icon(Icons.picture_as_pdf, color: Colors.white),
            label: Text(
              isLoading
                  ? 'Generating…'
                  : 'Export PDF  (${_languageLabel(_selectedLanguage)})',
              style: const TextStyle(color: Colors.white),
            ),
            onPressed:
                isLoading
                    ? null
                    : () {
                      if (_availableLanguages.length > 1) {
                        // Ask user to confirm / change language before export.
                        _showLanguagePicker(onSelected: _exportPdf);
                      } else {
                        _exportPdf();
                      }
                    },
          );
        },
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────────────────────

  Widget _buildPerformanceSummary() {
    if (widget.performanceSummary == null) return const SizedBox.shrink();
    final p = widget.performanceSummary!;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Summary',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          12.hGap,
          Table(
            columnWidths: const {
              0: FlexColumnWidth(0.8),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.0),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1.0),
            },
            border: TableBorder.all(color: Colors.black, width: 1),
            children: [
              TableRow(
                children: const [
                  _TableHeaderCell('Total'),
                  _TableHeaderCell('Attempted'),
                  _TableHeaderCell('Correct'),
                  _TableHeaderCell('Incorrect'),
                  _TableHeaderCell('Skipped'),
                ],
              ),
              TableRow(
                children: [
                  _TableCell(p.totalQuestions.toString()),
                  _TableCell(p.attemptedQuestions.toString()),
                  _TableCell(p.correctAnswers.toString()),
                  _TableCell(p.inCorrectAnswers.toString()),
                  _TableCell(p.notAttemptedQuestions.toString()),
                ],
              ),
            ],
          ),
          20.hGap,
          Table(
            columnWidths: const {
              0: FlexColumnWidth(0.8),
              1: FlexColumnWidth(1.0),
              2: FlexColumnWidth(1.3),
              3: FlexColumnWidth(1.0),
            },
            border: TableBorder.all(color: Colors.black, width: 1),
            children: [
              TableRow(
                children: const [
                  _TableHeaderCell('Rank'),
                  _TableHeaderCell('Score'),
                  _TableHeaderCell('Accuracy'),
                  _TableHeaderCell('Topper'),
                ],
              ),
              TableRow(
                children: [
                  _TableCell(p.userRank.toString()),
                  _TableCell(p.score.toStringAsFixed(1)),
                  _TableCell(
                    "${((p.correctAnswers / (p.totalQuestions == 0 ? 1 : p.totalQuestions)) * 100).toStringAsFixed(0)}%",
                  ),
                  _TableCell(p.topScore.toStringAsFixed(1)),
                ],
              ),
            ],
          ),
          10.hGap,
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionLanguageData q, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Card(
        color: AppColors.accentColor,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${index + 1}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
              8.hGap,
              MarkdownWidget(data: q.questionTxt, shrinkWrap: true),
              8.hGap,
              Text(q.optA),
              Text(q.optB),
              Text(q.optC),
              Text(q.optD),
              8.hGap,
              Text(
                'Answer: ${q.correctAnswer} ${_getAnswerText(q)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              if (widget.detailedResults != null) ...[
                () {
                  final userResult = widget.detailedResults!.firstWhere(
                    (r) => r.questionId == widget.questions[index].questionId,
                    orElse:
                        () => DetailedTestResult(
                          userId: 0,
                          testId: 0,
                          questionId: 0,
                          isCorrect: false,
                          attemptNo: 0,
                          timeSpent: 0,
                          selectedOption: '',
                        ),
                  );
                  if (userResult.selectedOption != null &&
                      userResult.selectedOption!.isNotEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        'Your answer: ${userResult.selectedOption}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: userResult.isCorrect ? Colors.blue : Colors.red,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }(),
              ],
              8.hGap,
              if (q.explanation.trim().isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Explanation:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    4.hGap,
                    MarkdownWidget(
                      data: q.explanation,
                      shrinkWrap: true,
                      selectable: true,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAnswerText(QuestionLanguageData q) {
    switch (q.correctAnswer.trim().toUpperCase()) {
      case 'A':
        return q.optA;
      case 'B':
        return q.optB;
      case 'C':
        return q.optC;
      case 'D':
        return q.optD;
      default:
        return '';
    }
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String label;

  const _TableHeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      child: Text(
        label,
        textAlign: TextAlign.center,
        softWrap: false,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String value;

  const _TableCell(this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15.sp),
      ),
    );
  }
}

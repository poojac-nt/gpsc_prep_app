import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/question%20preview/question_preview_bloc.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:markdown_widget/markdown_widget.dart';

class QuestionPreviewScreen extends StatelessWidget {
  const QuestionPreviewScreen({
    super.key,
    required this.questions,
    required this.testName,
  });

  final List<QuestionModel> questions;
  final String testName;

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
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
      ),
      body: BlocListener<QuestionPreviewBloc, QuestionPreviewState>(
        listener: (context, state) {
          if (state is QuestionExported) {
            getIt<SnackBarHelper>().showSuccess("PDF Downloaded Successfully");
          }
          if (state is QuestionExportError) {
            getIt<SnackBarHelper>().showError(state.failure.message);
          }
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final ln =
                getIt<CacheManager>()
                    .userSelectedLanguage(); // e.g., "en", "hi", "gj"
            QuestionLanguageData getLangData(QuestionModel q) {
              switch (ln) {
                case 'hi':
                  return q.questionHi ?? q.questionEn;
                case 'gj':
                  return q.questionGj ?? q.questionEn;
                case 'en':
                default:
                  return q.questionEn;
              }
            }

            final q = getLangData(questions[index]);
            return _buildQuestionCard(q, index);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Export PDF'),
        onPressed: () {
          questions.isNotEmpty
              ? context.read<QuestionPreviewBloc>().add(
                ExportQuestionsToPdfEvent(questions, testName),
              )
              : null;
        },
      ),
    );
  }

  Widget _buildQuestionCard(QuestionLanguageData q, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              MarkdownWidget(data: q.questionTxt, shrinkWrap: true),
              const SizedBox(height: 8),
              Text(q.optA),
              Text(q.optB),
              Text(q.optC),
              Text(q.optD),
              const SizedBox(height: 8),
              Text(
                'Answer: ${q.correctAnswer} ${_getAnswerText(q)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
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
                    const SizedBox(height: 4),
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

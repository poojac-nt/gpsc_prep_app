import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/question%20preview/question_preview_bloc.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:markdown_widget/markdown_widget.dart';

class QuestionPreviewScreen extends StatelessWidget {
  const QuestionPreviewScreen({super.key, required this.testName});

  final String testName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Questions')),
      body: BlocConsumer<QuestionPreviewBloc, QuestionPreviewState>(
        listener: (context, state) {
          if (state is QuestionExported) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PDF saved to: ${state.filePath}')),
            );
          } else if (state is QuestionPreviewError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          List<QuestionModel> localizedQuestions = [];
          if (state is QuestionPreviewLoaded) {
            localizedQuestions = state.questions;
          } else if (state is QuestionExported) {
            localizedQuestions = state.questions;
          }
          if (state is QuestionExporting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (localizedQuestions.isEmpty) {
            return const Center(child: Text('No questions available.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: localizedQuestions.length,
            itemBuilder: (context, index) {
              final q = localizedQuestions[index];
              return _buildQuestionCard(q.questionEn, index);
            },
          );
        },
      ),
      floatingActionButton: Builder(
        builder: (context) {
          List<QuestionModel> currentQuestions = [];
          final state = context.watch<QuestionPreviewBloc>().state;
          if (state is QuestionPreviewLoaded) {
            currentQuestions = state.questions;
          } else if (state is QuestionExported) {
            currentQuestions = state.questions;
          }

          return FloatingActionButton.extended(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF'),
            onPressed:
                currentQuestions.isNotEmpty
                    ? () {
                      context.read<QuestionPreviewBloc>().add(
                        ExportQuestionsToPdfEvent(currentQuestions, testName),
                      );
                    }
                    : null,
          );
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
              Text('${q.optA}'),
              Text('${q.optB}'),
              Text('${q.optC}'),
              Text('${q.optD}'),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:gpsc_prep_app/preview_screen/question_preview_bloc.dart';
import 'package:markdown_widget/markdown_widget.dart';

List<QuestionLanguageData> dummy = [
  QuestionLanguageData(
    optA: "optA",
    optB: 'optB',
    optC: 'optC',
    optD: 'optD',
    explanation: 'explanation',
    questionTxt: 'questionTxt',
    correctAnswer: 'optD',
  ),
  QuestionLanguageData(
    optA: "Stomach",
    optB: "Small intestine",
    optC: "Liver",
    optD: "Pancreas",
    explanation: '''
The liver is the largest internal organ in the human body and performs several important functions.

One of its key roles is to produce bile, a yellow-green fluid that helps in the digestion and absorption of fats.

Bile does not contain enzymes but contains bile salts, which emulsify fats (break large fat globules into smaller ones), making it easier for lipase to act on them.
                  ''',
    questionTxt:
        "**Which organ is responsible for producing bile in the animal body?**",
    correctAnswer: "option_c",
  ),
  QuestionLanguageData(
    optA: "A–2, B–1, C–3, D–4",
    optB: "A–3, B–2, C–1, D–4",
    optC: "A–1, B–4, C–2, D–3",
    optD: "A–2, B–3, C–1, D–4",
    explanation: '''
**Pepsin → Proteins (2):** 

Pepsin is an enzyme secreted by the stomach and helps break down proteins into smaller peptides.
    
**Lipase → Fats (1):**

Lipase is an enzyme produced by the pancreas that helps in the digestion of fats into fatty acids and glycerol.

**Amylase → Starch (3):**

Amylase is found in saliva and also secreted by the pancreas, and it helps convert starch into sugars.

**Trypsin → Proteins in the small intestine (4):**

Trypsin is secreted by the pancreas and works in the small intestine, continuing protein digestion started by pepsin.
                  ''',
    questionTxt:
        '''
**Dont Match the enzymes with the substances they act on:**

| Enzymes | Substances |
| --- | --- |
| A. Pepsin | 1. Fats |
| B. Lipase | 2. Proteins |
| C. Amylase | 3. Starch |
| D. Trypsin | 4. Proteins in the small intestine |
        ''',
    correctAnswer: "option_a",
  ),
];

class QuestionPreviewScreen extends StatelessWidget {
  const QuestionPreviewScreen({super.key});

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
          // 👇 Handle both loaded and exported states
          List<QuestionLanguageData> localizedQuestions = dummy;

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
              return _buildQuestionCard(q, index);
            },
          );
        },
      ),
      floatingActionButton: Builder(
        builder: (context) {
          // final state = context.watch<QuestionPreviewBloc>().state;
          List<QuestionLanguageData> currentQuestions = dummy;

          // if (state is QuestionPreviewLoaded) {
          //   currentQuestions = state.questions;
          // } else if (state is QuestionExported) {
          //   currentQuestions = state.questions;
          // }

          return FloatingActionButton.extended(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF'),
            onPressed:
                currentQuestions.isNotEmpty
                    ? () {
                      context.read<QuestionPreviewBloc>().add(
                        ExportQuestionsToPdfEvent(currentQuestions),
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
              Text('A) ${q.optA}'),
              Text('B) ${q.optB}'),
              Text('C) ${q.optC}'),
              Text('D) ${q.optD}'),
              const SizedBox(height: 8),
              Text(
                'Answer: ${q.correctAnswer}) ${_getAnswerText(q)}',
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<QuestionBloc>().add(
      LoadDescQuestion(widget.args.descTestModel.id, widget.args.language),
    );
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
                String resolveQuestionText() {
                  final language = widget.args.language;
                  switch (language) {
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

                return QuestionTile(
                  index: index,
                  questionText: resolveQuestionText(),
                  onTap: () {
                    context.push(
                      AppRoutes.descAnswerDetail,
                      extra: DescriptiveAnswerDetailScreenArgs(
                        question: question,
                        index: index,
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

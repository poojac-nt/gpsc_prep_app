import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/question/question_bloc.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/presentation/widgets/desc_question_tile.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DescriptiveAnswersScreen extends StatefulWidget {
  final DescTestModel descTestModel;

  const DescriptiveAnswersScreen({super.key, required this.descTestModel});

  @override
  State<DescriptiveAnswersScreen> createState() =>
      _DescriptiveAnswersScreenState();
}

class _DescriptiveAnswersScreenState extends State<DescriptiveAnswersScreen> {
  @override
  void initState() {
    context.read<QuestionBloc>().add(
      LoadDescQuestion(widget.descTestModel.id, "en"),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Model Answers', style: AppTexts.titleTextStyle),
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
                return QuestionTile(
                  index: index,
                  questionText: question.questionEn.questionTxt,
                  onTap: () {
                    context.push(
                      AppRoutes.descAnswerDetail,
                      extra: {'question': question, 'index': index},
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
        itemBuilder:
            (context, index) => Container(
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

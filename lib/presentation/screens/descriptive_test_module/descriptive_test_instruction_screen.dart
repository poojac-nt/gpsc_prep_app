import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test/daily_descriptive_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/fetch_single_test/fetch_single_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/question/question_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/desc_question_tile.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';

import '../../../core/di/di.dart';
import '../../../core/helpers/snack_bar_helper.dart';
import '../../../utils/app_constants.dart';

class DescriptiveTestInstructionScreen extends StatefulWidget {
  final DescTestModel? descTestModel;
  final int? testId;
  final int? courseId;
  final bool isFromCourse;

  const DescriptiveTestInstructionScreen({
    super.key,
    this.descTestModel,
    this.testId,
    this.isFromCourse = false,
    this.courseId,
  });

  @override
  State<DescriptiveTestInstructionScreen> createState() =>
      _DescriptiveTestInstructionScreenState();
}

class _DescriptiveTestInstructionScreenState
    extends State<DescriptiveTestInstructionScreen> {
  late bool isFromId;
  DescTestModel? _fetchedTestModel;

  @override
  void initState() {
    super.initState();
    isFromId = widget.testId != null;
    context.read<QuestionBloc>().add(ResetQuestionState());

    if (isFromId) {
      context.read<FetchSingleTestBloc>().add(
        FetchSingleDescTestFromId(widget.testId!),
      );
      context.read<QuestionBloc>().add(LoadDescQuestion(widget.testId!, "en"));
    } else {
      context.read<QuestionBloc>().add(
        LoadDescQuestion(widget.descTestModel!.id, "en"),
      );
    }
    context.read<DailyDescTestBloc>().add(FetchAllTests());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FetchSingleTestBloc, FetchSingleTestState>(
      listenWhen: (_, state) => state is SingleDescTestFetched,
      listener: (_, state) {
        if (state is SingleDescTestFetched) {
          setState(() {
            _fetchedTestModel = state.descModel;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.descTestModel?.name ??
                _fetchedTestModel?.name ??
                "Loading...",
            style: AppTexts.titleTextStyle,
          ),
        ),
        body: BlocBuilder<DailyDescTestBloc, DailyDescTestState>(
          builder: (context, descState) {
            return BlocBuilder<QuestionBloc, QuestionState>(
              builder: (context, state) {
                if (state is QuestionLoading) return _loadingScreen();
                if (state is DescQuestionLoaded) {
                  return _buildQuestionList(state, descState);
                }
                if (state is QuestionLoadFailed) {
                  return _errorScreen(state.failure.message);
                }
                return _emptyScreen();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _loadingScreen() => const Center(child: CircularProgressIndicator());

  Widget _errorScreen(String message) =>
      Center(child: Text('Failed to load questions: $message'));

  Widget _emptyScreen() => const Center(child: Text('No Questions Available'));

  Widget _buildQuestionList(
    DescQuestionLoaded state,
    DailyDescTestState descState,
  ) {
    final model = widget.descTestModel ?? _fetchedTestModel;

    if (model == null) return _loadingScreen();

    // Check if test is already submitted
    bool hasAnswer = false;
    if (descState is DailyDescTestFetched) {
      hasAnswer = descState.answersMap.containsKey(model.id);
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 20),
      itemBuilder: (context, index) {
        final questionModel = state.questionsModels[index];
        final List<String> allowedLangs = model.allowedLanguages ?? [];
        final List<String> availableLangs = [];
        if (questionModel.questionEn.questionTxt.isNotEmpty) availableLangs.add('en');
        if (questionModel.questionHi?.questionTxt.isNotEmpty == true) availableLangs.add('hi');
        if (questionModel.questionGj?.questionTxt.isNotEmpty == true) availableLangs.add('gj');
        final List<String> intersect = allowedLangs.where((lang) => availableLangs.contains(lang)).toList();
        final String selectedLang = intersect.isNotEmpty ? intersect.first : (availableLangs.isNotEmpty ? availableLangs.first : 'en');
        String? questionText;
        switch (selectedLang) {
          case 'en':
            questionText = questionModel.questionEn.questionTxt;
            break;
          case 'hi':
            questionText = questionModel.questionHi?.questionTxt;
            break;
          case 'gj':
            questionText = questionModel.questionGj?.questionTxt;
            break;
        }
        questionText ??= '';

        return QuestionTile(
          index: index,
          questionText: questionText,
          onTap: () {
            if (isFromId && hasAnswer) {
              getIt<SnackBarHelper>().showSuccess(
                "This test has already been attempted!",
              );
              return;
            }
            context.push(
              AppRoutes.descriptiveTestScreen,
              extra: DescTestScreenArgs(
                dailyTestModel: model,
                initialIndex: index,
              ),
            );
          },
        );
      },
      separatorBuilder: (context, index) => 2.hGap,
      itemCount: state.questionsModels.length,
    );
  }
}

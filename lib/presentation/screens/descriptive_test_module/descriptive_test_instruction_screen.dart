import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/router/args.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';
import 'package:gpsc_prep_app/presentation/blocs/fetch_single_test/fetch_single_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/fetch_single_test/fetch_single_test_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/fetch_single_test/fetch_single_test_state.dart';
import 'package:gpsc_prep_app/presentation/blocs/question/question_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/desc_question_tile.dart';
import 'package:gpsc_prep_app/utils/extensions/padding.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test/daily_descriptive_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test/daily_descriptive_test_event.dart';
import 'package:gpsc_prep_app/presentation/blocs/descriptive_test/daily_descriptive_test_state.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/di/di.dart';

import '../../../utils/app_constants.dart';

class DescriptiveTestInstructionScreen extends StatefulWidget {
  final DescTestModel? descTestModel;
  final int? testId;
  final int? courseId;

  const DescriptiveTestInstructionScreen({
    super.key,
    this.descTestModel,
    this.testId,
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
    context.read<DailyDescTestBloc>().add(FetchAllTests(courseId: widget.courseId));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FetchSingleTestBloc, FetchSingleTestState>(
          listenWhen: (_, state) => state is SingleDescTestFetched,
          listener: (_, state) {
            if (state is SingleDescTestFetched) {
              setState(() {
                _fetchedTestModel = state.descModel;
              });
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.descTestModel?.name ??
                _fetchedTestModel?.name ??
                "Loading...",
            style: AppTexts.titleTextStyle,
          ),
        ),
        body: BlocBuilder<QuestionBloc, QuestionState>(
          builder: (context, state) {
            if (state is QuestionLoading) return _loadingScreen();
            if (state is DescQuestionLoaded) {
              return _buildQuestionList(state);
            }
            if (state is QuestionLoadFailed) {
              return _errorScreen(state.failure.message);
            }
            return _emptyScreen();
          },
        ),
      ),
    );
  }

  Widget _loadingScreen() => const Center(child: CircularProgressIndicator());

  Widget _errorScreen(String message) =>
      Center(child: Text('Failed to load questions: $message'));

  Widget _emptyScreen() => const Center(child: Text('No Questions Available'));

  Widget _buildQuestionList(DescQuestionLoaded state) {
    final model = widget.descTestModel ?? _fetchedTestModel;

    if (model == null) return _loadingScreen();

    return BlocBuilder<DailyDescTestBloc, DailyDescTestState>(
      builder: (context, descState) {
        final Map<int, dynamic> answersMap =
            (descState is DailyDescTestFetched) ? descState.answersMap : {};
        final bool isAttempted = answersMap.containsKey(model.id);

        return ListView.separated(
          itemBuilder: (context, index) {
            final q = state.questionsModels[index].questionEn;
            return QuestionTile(
              index: index,
              questionText: q.questionTxt,
              onTap: () {
                if (isAttempted) {
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
      },
    );
  }
}

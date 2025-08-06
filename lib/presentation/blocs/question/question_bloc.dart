import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/utils/enums/difficulty_level.dart';
import 'package:meta/meta.dart';

part 'question_event.dart';
part 'question_state.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  final TestRepository _testRepository;
  final log = getIt<LogHelper>();

  QuestionBloc(this._testRepository) : super(QuestionLoading()) {
    on<FetchQuestions>(_fetchQuestions);
    on<PrepareQuestions>(_prepareQuestions);
  }

  Future<void> _fetchQuestions(
    FetchQuestions event,
    Emitter<QuestionState> emit,
  ) async {
    emit(QuestionFetching());

    final result = await _testRepository.fetchTestQuestions(event.testId);

    result.fold(
      (failure) => emit(QuestionLoadFailed(failure)),
      (questions) => add(PrepareQuestions(questionsModels: questions)),
    );
  }

  Future<void> _prepareQuestions(
    PrepareQuestions event,
    Emitter<QuestionState> emit,
  ) async {
    emit(QuestionLoading());

    try {
      final questions = event.questionsModels;

      if (questions.isEmpty) {
        emit(QuestionLoadFailed(Failure("No questions available")));
        return;
      }
      emit(
        QuestionLoaded(
          questions: questions,
          marks: questions.map((e) => e.marks).toList(),
          subjects: questions.map((e) => e.subjectName).toList(),
          topics: questions.map((e) => e.topicName).toList(),
          difficultyLevel: questions.map((e) => e.difficultyLevel).toList(),
        ),
      );
    } catch (e) {
      emit(QuestionLoadFailed(Failure("Error preparing questions")));
    }
  }
}

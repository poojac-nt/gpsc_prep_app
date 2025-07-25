import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:meta/meta.dart';


part 'question_event.dart';
part 'question_state.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  final TestRepository _testRepository;
  final log = getIt<LogHelper>();

  QuestionBloc(this._testRepository) : super(QuestionLoading()) {
    on<LoadQuestion>(_loadQuestion);
  }

  Future<void> _loadQuestion(
    LoadQuestion event,
    Emitter<QuestionState> emit,
  ) async {
    final result = await _testRepository.fetchTestQuestions(event.testId);

    result.fold((failure) => emit(QuestionLoadFailed(failure)), (questions) {
      List<QuestionLanguageData> localizedQuestions;
      List<int> marks =
          questions
              .where((q) => q.marks != 0)
              .map((q) => q.marks) // Ensure only valid entries
              .toList();
      print('MArksss:$marks');
      switch (event.language) {
        case 'hi':
          localizedQuestions =
              questions
                  .map((e) => e.questionHi)
                  .whereType<QuestionLanguageData>()
                  .toList();
          break;
        case 'en':
          localizedQuestions =
              questions
                  .map((e) => e.questionEn)
                  .whereType<QuestionLanguageData>()
                  .toList();
          break;
        case 'gj':
          localizedQuestions =
              questions
                  .map((e) => e.questionGj)
                  .whereType<QuestionLanguageData>()
                  .toList();
          break;
        default:
          emit(QuestionLoadFailed(Failure("Unsupported language")));
          return;
      }

      if (localizedQuestions.isEmpty) {
        emit(
          QuestionLoadFailed(
            Failure("No questions available in selected language"),
          ),
        );
        return;
      }

      emit(QuestionLoaded(questions: localizedQuestions, marks: marks));
    });
  }
}

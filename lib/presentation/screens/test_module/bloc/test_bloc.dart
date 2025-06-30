import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test_event.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test_state.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  QuestionBloc() : super(QuestionInitial()) {
    on<LoadQuestion>(_loadQuestion);
    on<AnswerQuestion>(_answerQuestion);
    on<NextQuestion>(_nextQuestion);
    on<PrevQuestion>(_prevQuestion);
    on<JumpToQuestion>(_jumpToQuestion);
  }
  Future<void> _loadQuestion(
    LoadQuestion event,
    Emitter<QuestionState> emit,
  ) async {
    final questions = [
      {
        'id': 1,
        'question': 'What is Flutter?',
        'option 1': 'Flutter is a framework',
        'option 2': 'Flutter is a programming language',
        'option 3': 'Flutter is a widget library',
        'option 4': 'Flutter is a mobile app development platform',
      },
      {
        'id': 2,
        'question': 'What is Dart?',
        'option 1': 'Dart is a programming language',
        'option 2': 'Dart is a framework',
        'option 3': 'Dart is a widget library',
        'option 4': 'Dart is a mobile app development platform',
      },
      {
        'id': 3,
        'question': 'What is State Management.',
        'option 1': 'State Management is a framework',
        'option 2': 'State Management is a programming language',
        'option 3': 'State Management is a widget library',
        'option 4': 'State Management is a mobile app development platform',
      },
      {
        'id': 4,
        'question': 'What is a Widget?',
        'option 1': 'A Widget is a framework',
        'option 2': 'A Widget is a programming language',
        'option 3': 'A Widget is a widget library',
        'option 4': 'A Widget is a mobile app development platform',
      },
    ];
    emit(
      QuestionLoaded(
        questions: questions,
        currentIndex: 0,
        answeredStatus: List.generate(questions.length, (_) => false),
      ),
    );
  }

  Future<void> _answerQuestion(
    AnswerQuestion event,
    Emitter<QuestionState> emit,
  ) async {
    if (state is QuestionLoaded) {
      final currentState = state as QuestionLoaded;
      final updatedAnsweredStatus = [...currentState.answeredStatus];
      updatedAnsweredStatus[currentState.currentIndex] = true;
      emit(currentState.copyWith(answeredStatus: updatedAnsweredStatus));
    }
  }

  Future<void> _nextQuestion(
    NextQuestion event,
    Emitter<QuestionState> emit,
  ) async {
    if (state is QuestionLoaded) {
      final currentState = state as QuestionLoaded;
      final nextIndex = currentState.currentIndex + 1;
      if (nextIndex < currentState.questions.length) {
        emit(currentState.copyWith(currentIndex: nextIndex));
      }
    }
  }

  Future<void> _prevQuestion(
    PrevQuestion event,
    Emitter<QuestionState> emit,
  ) async {
    if (state is QuestionLoaded) {
      final currentState = state as QuestionLoaded;
      final prevIndex = currentState.currentIndex - 1;
      if (prevIndex >= 0) {
        emit(currentState.copyWith(currentIndex: prevIndex));
      }
    }
  }

  Future<void> _jumpToQuestion(
    JumpToQuestion event,
    Emitter<QuestionState> emit,
  ) async {
    if (state is QuestionLoaded) {
      final currentState = state as QuestionLoaded;
      final index = event.index;
      emit(currentState.copyWith(currentIndex: index));
    }
  }
}

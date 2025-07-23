import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/pdf_export_service.dart';
import 'package:meta/meta.dart';

part 'question_preview_event.dart';
part 'question_preview_state.dart';

class QuestionPreviewBloc
    extends Bloc<QuestionPreviewEvent, QuestionPreviewState> {
  QuestionPreviewBloc() : super(QuestionPreviewInitial()) {
    on<LoadQuestionsEvent>(_onLoadQuestions);
    on<ExportQuestionsToPdfEvent>(_onExportQuestionsToPdf);
  }

  void _onLoadQuestions(
    LoadQuestionsEvent event,
    Emitter<QuestionPreviewState> emit,
  ) {
    final ln =
        getIt<CacheManager>().userSelectedLanguage(); // e.g., "en", "hi", "gj"

    QuestionLanguageData getLangData(QuestionModel q) {
      switch (ln) {
        case 'hi':
          return q.questionEn;
        case 'gj':
          return q.questionEn;
        case 'en':
        default:
          return q.questionEn;
      }
    }

    final questions =
        event.questions.map((q) {
          final langData = getLangData(q);
          return QuestionLanguageData(
            correctAnswer: langData.correctAnswer,
            questionTxt: langData.questionTxt,
            optA: langData.optA,
            optB: langData.optB,
            optC: langData.optC,
            optD: langData.optD,
            explanation: langData.explanation,
          );
        }).toList();

    emit(QuestionPreviewLoaded(questions));
  }

  Future<void> _onExportQuestionsToPdf(
    ExportQuestionsToPdfEvent event,
    Emitter<QuestionPreviewState> emit,
  ) async {
    try {
      emit(QuestionExporting());
      final path = await PdfExportService().exportQuestionsToPdf(
        event.questions,
      );
      emit(QuestionExported(questions: event.questions, filePath: path));
    } catch (e) {
      emit(QuestionPreviewError('Failed to export PDF'));
    }
  }
}

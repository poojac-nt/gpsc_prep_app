import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/preview_screen/pdf_export_service.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';

part 'question_preview_event.dart';
part 'question_preview_state.dart';

class QuestionPreviewBloc
    extends Bloc<QuestionPreviewEvent, QuestionPreviewState> {
  final log = getIt.get<LogHelper>();

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
          return q.questionHi ?? q.questionEn;
        case 'gj':
          return q.questionGj ?? q.questionEn;
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
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
      final path = await PdfExportService().exportQuestionsToPdf(
        event.questions,
        event.testName,
      );

      emit(
        QuestionExported(
          questions: event.questions,
          filePath: path,
          testName: event.testName,
        ),
      );
    } catch (e) {
      log.e('Error exporting questions to PDF: $e');
      emit(QuestionPreviewError('Failed to export PDF'));
    }
  }
}

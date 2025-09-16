import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/domain/entities/question_language_model.dart';
import 'package:gpsc_prep_app/domain/entities/question_model.dart';
import 'package:gpsc_prep_app/presentation/screens/preview_screen/pdf_export_service.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

part 'question_preview_event.dart';
part 'question_preview_state.dart';

class QuestionPreviewBloc
    extends Bloc<QuestionPreviewEvent, QuestionPreviewState> {
  final _log = getIt<LogHelper>();

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

    emit(QuestionPreviewLoaded(event.questions));
  }

  Future<void> _onExportQuestionsToPdf(
    ExportQuestionsToPdfEvent event,
    Emitter<QuestionPreviewState> emit,
  ) async {
    try {
      emit(QuestionExporting());
      final Directory? outputDir;
      if (Platform.isAndroid &&
          (await DeviceInfoPlugin().androidInfo).version.sdkInt >= 30) {
        outputDir = await getExternalStorageDirectory();
      } else {
        outputDir =
            await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      }

      final result = await PdfExportService().exportQuestionsToPdf(
        event.questions,
        event.testName,
      );
      if (result.isEmpty) {
        _log.e("Failed to generate PDF");
        emit(QuestionPreviewError("Failed to generate PDF"));
        return;
      }
      _log.i("PDF generated successfully: $result");
      emit(
        QuestionExported(
          questions: event.questions,
          filePath: result,
          testName: event.testName,
        ),
      );
    } catch (e) {
      _log.e('Error exporting questions to PDF: $e');
      emit(QuestionPreviewError('Failed to export PDF'));
    }
  }
}

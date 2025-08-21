import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/presentation/screens/descriptive_test_module/desc_pdf_download.dart';
import 'package:permission_handler/permission_handler.dart';

import 'daily_descriptive_test_event.dart';
import 'daily_descriptive_test_state.dart';

class DailyDescTestBloc extends Bloc<DailyDescTestEvent, DailyDescTestState> {
  final TestRepository _testRepository;
  final _snackBar = getIt<SnackBarHelper>();
  final _log = getIt<LogHelper>();

  /// Keep text answers and pdf answers separately
  final Map<int, String> _answers = {};
  final Map<int, File?> _pdfCache = {};

  DailyDescTestBloc(this._testRepository) : super(DailyTestInitial()) {
    on<FetchAllTests>(_fetchAllTests);
    on<AddTextAnswer>(_addTextAnswer);
    on<AddPdfAnswer>(_addPdfAnswer);
    on<RemoveAnswer>(_removeAnswer);
    on<SubmitDescTest>(_submitDescTest);
    on<DownloadDescTestPdf>(_downloadDescTestPdf);
  }

  /// Fetch all tests
  Future<void> _fetchAllTests(
    FetchAllTests event,
    Emitter<DailyDescTestState> emit,
  ) async {
    emit(DailyDescTestFetching());
    final testsResult = await _testRepository.fetchDailyDescTest();
    testsResult.fold((failure) => emit(DailyDescTestFetchFailed(failure)), (
      tests,
    ) {
      if (tests.isEmpty) {
        _log.e("No descriptive tests available at the moment.");
        emit(
          DailyDescTestFetchFailed(Failure('No tests available at the moment')),
        );
        return;
      }
      emit(DailyDescTestFetched(tests));
      _log.i("Fetched ${tests.length} descriptive tests successfully.");
    });
  }

  /// Add a text answer (clears PDF if it exists)
  void _addTextAnswer(AddTextAnswer event, Emitter<DailyDescTestState> emit) {
    _answers[event.questionId] = event.text;

    String? message;
    if (_pdfCache.containsKey(event.questionId)) {
      _pdfCache.remove(event.questionId);
      message = "PDF will not be saved because you typed text.";
      _log.i(message);
    }

    if (message != null) {
      _snackBar.showSuccess(message);
      _log.i("Showing snackbar: $message");
      emit(
        DailyDescTestMessage(
          message: message,
          answers: Map.from(_answers),
          pdfCache: Map.from(_pdfCache),
        ),
      );
    } else {
      _log.i("No PDF answer to clear, just updating text answer.");
      emit(
        DailyDescTestInProgress(
          answers: Map.from(_answers),
          pdfCache: Map.from(_pdfCache),
        ),
      );
    }
  }

  /// Add a PDF answer (clears text if it exists)
  void _addPdfAnswer(AddPdfAnswer event, Emitter<DailyDescTestState> emit) {
    _pdfCache[event.questionId] = event.file;

    String? message;
    if (_answers.containsKey(event.questionId)) {
      _answers.remove(event.questionId);
      _log.i("Text answer cleared because you uploaded a PDF.");
      message = "Text will not be saved because you uploaded a PDF.";
    }

    if (message != null) {
      _snackBar.showSuccess(message);
      emit(
        DailyDescTestMessage(
          message: message,
          answers: Map.from(_answers),
          pdfCache: Map.from(_pdfCache),
        ),
      );
    } else {
      _log.i("No text answer to clear, just updating PDF answer.");
      emit(
        DailyDescTestInProgress(
          answers: Map.from(_answers),
          pdfCache: Map.from(_pdfCache),
        ),
      );
    }
  }

  /// Remove answer completely
  void _removeAnswer(RemoveAnswer event, Emitter<DailyDescTestState> emit) {
    _answers.remove(event.questionId);
    _pdfCache.remove(event.questionId);

    emit(
      DailyDescTestInProgress(
        answers: Map.from(_answers),
        pdfCache: Map.from(_pdfCache),
      ),
    );
    _log.i("Removed answer for question ${event.questionId}.");
  }

  /// Submit the test
  Future<void> _submitDescTest(
    SubmitDescTest event,
    Emitter<DailyDescTestState> emit,
  ) async {
    emit(DescTestSubmit());

    try {
      // 1. Upload PDFs first and replace with URLs
      final Map<int, String> finalAnswers = Map.from(_answers);

      for (final entry in _pdfCache.entries) {
        final int questionId = entry.key;
        final File? file = entry.value;

        if (file != null) {
          final result = await _testRepository.uploadPdfAnswer(
            event.testId,
            questionId,
            file,
          );

          result.fold(
            (failure) {
              _log.e("Failed to upload PDF for question $questionId: $failure");
              emit(DescTestSubmitFailed(failure));
            },
            (url) {
              finalAnswers[questionId] = url; // store PDF URL as answer
            },
          );
        }
      }

      // 2. Submit final answers (both text + pdf urls)
      final submitResult = await _testRepository.submitDescriptiveTest(
        event.testId,
        finalAnswers,
      );

      submitResult.fold(
        (failure) {
          _log.e("Failed to submit descriptive test: $failure");
          emit(DescTestSubmitFailed(failure));
        },
        (message) {
          emit(DescTestSubmitSuccess("Test submitted successfully!"));
          _log.i("Descriptive test submitted successfully");
        },
      );
    } catch (e) {
      _log.e("Error submitting descriptive test: $e");
      emit(DescTestSubmitFailed(Failure(e.toString())));
    }
  }

  Future<void> _downloadDescTestPdf(
    DownloadDescTestPdf event,
    Emitter<DailyDescTestState> emit,
  ) async {
    emit(PdfDownloadInit());

    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 30) {
        if (!await Permission.manageExternalStorage.isGranted) {
          await Permission.manageExternalStorage.request();
        }
        if (!await Permission.manageExternalStorage.isGranted) {
          emit(PdfDownloadFailure(Failure('Storage permission denied')));
          return;
        }
      } else {
        if (!await Permission.storage.isGranted) {
          await Permission.storage.request();
        }
        if (!await Permission.storage.isGranted) {
          emit(PdfDownloadFailure(Failure('Storage permission denied')));
          return;
        }
      }

      final result = await generateDescTestPdf(
        event.questionId,
        event.index,
        event.testName,
      );

      if (result.isEmpty) {
        _log.e("Failed to generate PDF for question ${event.questionId.id}");
        emit(PdfDownloadFailure(Failure("Failed to generate PDF")));
        return;
      }
      _log.i("PDF generated successfully: $result");
      emit(PdfDownloadSuccess(result));
      _snackBar.showSuccess("PDF downloaded successfully: $result");
    } catch (e) {
      _log.e("Error downloading PDF: $e");
      emit(PdfDownloadFailure(Failure(e.toString())));
    }
  }
}

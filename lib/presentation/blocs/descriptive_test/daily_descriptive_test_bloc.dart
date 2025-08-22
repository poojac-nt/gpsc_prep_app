import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/desc_answer_model.dart';
import 'package:gpsc_prep_app/presentation/screens/descriptive_test_module/desc_pdf_download.dart';
import 'package:permission_handler/permission_handler.dart';

import 'daily_descriptive_test_event.dart';
import 'daily_descriptive_test_state.dart';

class DailyDescTestBloc extends Bloc<DailyDescTestEvent, DailyDescTestState> {
  final TestRepository _testRepository;
  final _snackBar = getIt<SnackBarHelper>();
  final _log = getIt<LogHelper>();

  /// Keep text answers and files (PDFs/images) separately
  final Map<int, String> _answers = {};
  final Map<int, List<File>> _fileCache = {}; // updated to hold multiple files

  DailyDescTestBloc(this._testRepository) : super(DailyTestInitial()) {
    on<FetchAllTests>(_fetchAllTests);
    on<AddTextAnswer>(_addTextAnswer);
    on<AddFilesAnswer>(_addFilesAnswer);
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

    // 1. Fetch all descriptive tests
    final testsResult = await _testRepository.fetchDailyDescTest();

    await testsResult.fold(
      (failure) async {
        emit(DailyDescTestFetchFailed(failure));
      },
      (tests) async {
        if (tests.isEmpty) {
          _log.e("No descriptive tests available at the moment.");
          emit(
            DailyDescTestFetchFailed(
              Failure('No tests available at the moment'),
            ),
          );
          return;
        }

        // 2. Fetch answers for each test
        final answersMap = <int, List<DescAnswerModel>>{};
        final userId = getIt<CacheManager>().getUserId();

        for (final test in tests) {
          final answersResult = await _testRepository.fetchAnswersForTest(
            test.id,
            userId,
          );

          answersResult.fold((_) {}, (ansList) {
            if (ansList.isNotEmpty) {
              answersMap[test.id] = ansList;
            }
          });
        }

        // 3. Emit success state with both tests and answers
        emit(DailyDescTestFetched(tests, answersMap));
        _log.i("Fetched ${tests.length} descriptive tests successfully.");
      },
    );
  }

  /// Add a text answer (clears file cache if it exists)
  void _addTextAnswer(AddTextAnswer event, Emitter<DailyDescTestState> emit) {
    _answers[event.questionId] = event.text;

    String? message;
    if (_fileCache.containsKey(event.questionId)) {
      _fileCache.remove(event.questionId);
      message = "Files will not be saved because you typed text.";
      _log.i(message);
    }

    if (message != null) {
      _snackBar.showSuccess(message);
      _log.i("Showing snackbar: $message");
      emit(
        DailyDescTestMessage(
          message: message,
          answers: Map.from(_answers),
          pdfCache: Map.from(_fileCache),
        ),
      );
    } else {
      _log.i("No file answer to clear, just updating text answer.");
      emit(
        DailyDescTestInProgress(
          answers: Map.from(_answers),
          pdfCache: Map.from(_fileCache),
        ),
      );
    }
  }

  /// Add files (PDFs/images) answer (clears text if it exists)
  void _addFilesAnswer(AddFilesAnswer event, Emitter<DailyDescTestState> emit) {
    // Store multiple files for this question
    _fileCache[event.questionId] = event.files;

    String? message;

    // Clear any existing text answer for this question
    if (_answers.containsKey(event.questionId)) {
      _answers.remove(event.questionId);
      _log.i("Text answer cleared because you uploaded files.");
      message = "Text will not be saved because you uploaded files.";
    }

    // Emit state based on whether there was a message
    if (message != null) {
      _snackBar.showSuccess(message);
      emit(
        DailyDescTestMessage(
          message: message,
          answers: Map.from(_answers),
          pdfCache: Map.from(_fileCache),
        ),
      );
    } else {
      _log.i("No text answer to clear, just updating file answers.");
      emit(
        DailyDescTestInProgress(
          answers: Map.from(_answers),
          pdfCache: Map.from(_fileCache),
        ),
      );
    }
  }

  /// Remove answer completely
  void _removeAnswer(RemoveAnswer event, Emitter<DailyDescTestState> emit) {
    _answers.remove(event.questionId);
    _fileCache.remove(event.questionId);

    emit(
      DailyDescTestInProgress(
        answers: Map.from(_answers),
        pdfCache: Map.from(_fileCache),
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
      // 1. Prepare final answers map
      final Map<int, dynamic> finalAnswers = Map.from(_answers); // text answers

      // 2. Upload files for each question
      for (final entry in _fileCache.entries) {
        final int questionId = entry.key;
        final List<File> files = entry.value;

        if (files.isNotEmpty) {
          final result = await _testRepository.uploadPdfAnswer(
            event.testId,
            questionId,
            files,
          );

          result.fold(
            (failure) {
              _log.e(
                "Failed to upload files for question $questionId: $failure",
              );
              emit(DescTestSubmitFailed(failure));
              return; // stop further processing on failure
            },
            (urls) {
              // store list of file URLs as answer
              finalAnswers[questionId] = urls;
              _log.i(
                "Files uploaded successfully for question $questionId: $urls",
              );
            },
          );
        }
      }

      // 3. Submit final answers (text + file URLs)
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

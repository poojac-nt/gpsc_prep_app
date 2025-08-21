import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/domain/entities/desc_answer_model.dart';
import 'package:gpsc_prep_app/domain/entities/desc_test_model.dart';

@immutable
sealed class DailyDescTestState {}

/// Initial state
final class DailyTestInitial extends DailyDescTestState {}

/// Fetching descriptive tests
final class DailyDescTestFetching extends DailyDescTestState {}

/// Fetched descriptive tests successfully
final class DailyDescTestFetched extends DailyDescTestState {
  final List<DescTestModel> dailyTestModel;
  final Map<int, List<DescAnswerModel>> answersMap;

  DailyDescTestFetched(this.dailyTestModel, this.answersMap);
}

/// Failed fetching descriptive tests
final class DailyDescTestFetchFailed extends DailyDescTestState {
  final Failure failure;

  DailyDescTestFetchFailed(this.failure);
}

/// Submitting descriptive test
final class DescTestSubmit extends DailyDescTestState {}

/// Failed submission
final class DescTestSubmitFailed extends DailyDescTestState {
  final Failure failure;

  DescTestSubmitFailed(this.failure);
}

/// Successful submission
final class DescTestSubmitSuccess extends DailyDescTestState {
  final String message;

  DescTestSubmitSuccess(this.message);
}

/// 🔑 Ongoing test session state (text answers + pdf answers in memory)
final class DailyDescTestInProgress extends DailyDescTestState {
  final Map<int, String> answers; // text answers
  final Map<int, File?> pdfCache; // pdf answers

  DailyDescTestInProgress({required this.answers, required this.pdfCache});

  DailyDescTestInProgress copyWith({
    Map<int, String>? answers,
    Map<int, File?>? pdfCache,
  }) {
    return DailyDescTestInProgress(
      answers: answers ?? this.answers,
      pdfCache: pdfCache ?? this.pdfCache,
    );
  }
}

/// 🔑 State to notify user (e.g. when PDF clears text or text clears PDF)
final class DailyDescTestMessage extends DailyDescTestInProgress {
  final String message;

  DailyDescTestMessage({
    required this.message,
    required super.answers,
    required super.pdfCache,
  });
}

class AnswerState {
  String text;
  File? pdf;

  AnswerState({this.text = '', this.pdf});

  AnswerState copyWith({String? text, File? pdf}) {
    return AnswerState(text: text ?? this.text, pdf: pdf ?? this.pdf);
  }
}

final class PdfDownloadInit extends DailyDescTestState {}

final class PdfDownloadSuccess extends DailyDescTestState {
  final String filePath;

  PdfDownloadSuccess(this.filePath);
}

final class PdfDownloadFailure extends DailyDescTestState {
  final Failure failure;

  PdfDownloadFailure(this.failure);
}

part of 'download_pdf_bloc.dart';

@immutable
sealed class DownLoadPdfEvent {}

class ExportQuestionsToPdfEvent extends DownLoadPdfEvent {
  final String testName;
  final List<QuestionModel> questions;
  final TestResultWithTopScoreModel? performanceSummary;
  final TestType? testType;
  final List<DetailedTestResult>? detailedResults;
  final List<String> languages;
  final bool showAnswers;

  ExportQuestionsToPdfEvent(
    this.questions,
    this.testName, {
    this.performanceSummary,
    this.testType,
    this.detailedResults,
    this.languages = const ['en'],
    this.showAnswers = true,
    required String language,
  });
}

class DownloadDescTestPdf extends DownLoadPdfEvent {
  final DescQuestionModel question;
  final int index;
  final String testName;
  final List<String> langCodes;
  final bool showAnswers;

  DownloadDescTestPdf({
    required this.question,
    required this.index,
    required this.testName,
    required this.langCodes,
    this.showAnswers = true,
  });
}

class DownloadStudyMaterial extends DownLoadPdfEvent {
  final String url;
  final String filename;

  DownloadStudyMaterial({required this.url, required this.filename});
}

class DownloadPrelimsOmr extends DownLoadPdfEvent {
  final String url;
  final String filename;

  DownloadPrelimsOmr({required this.url, required this.filename});
}

class DownloadFullDescTestPdf extends DownLoadPdfEvent {
  final List<DescQuestionModel> questions;
  final String testName;
  final List<String> langCodes;
  final bool showAnswers;

  DownloadFullDescTestPdf({
    required this.questions,
    required this.testName,
    required this.langCodes,
    this.showAnswers = true,
  });
}

part of 'download_pdf_bloc.dart';

@immutable
sealed class DownLoadPdfEvent {}

class ExportQuestionsToPdfEvent extends DownLoadPdfEvent {
  final String testName;
  final List<QuestionModel> questions;
  final TestResultWithTopScoreModel? performanceSummary;
  final TestType? testType;
  final List<DetailedTestResult>? detailedResults;
  final String language;

  ExportQuestionsToPdfEvent(
    this.questions,
    this.testName, {
    this.performanceSummary,
    this.testType,
    this.detailedResults,
    this.language = 'en',
  });
}

class DownloadDescTestPdf extends DownLoadPdfEvent {
  final DescQuestionModel question;
  final int index;
  final String testName;
  final List<String> langCodes;

  DownloadDescTestPdf({
    required this.question,
    required this.index,
    required this.testName,
    required this.langCodes,
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

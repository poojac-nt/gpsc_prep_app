part of 'download_pdf_bloc.dart';

@immutable
sealed class DownLoadPdfEvent {}

class ExportQuestionsToPdfEvent extends DownLoadPdfEvent {
  final String testName;
  final List<QuestionModel> questions;

  ExportQuestionsToPdfEvent(this.questions, this.testName);
}

class DownloadDescTestPdf extends DownLoadPdfEvent {
  final DescQuestionModel question;
  final int index;
  final String testName;

  DownloadDescTestPdf({
    required this.question,
    required this.index,
    required this.testName,
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

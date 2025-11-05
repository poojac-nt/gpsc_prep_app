part of 'download_pdf_bloc.dart';

@immutable
sealed class DownLoadPdfState {}

final class DownLoadPdfInitial extends DownLoadPdfState {}

final class DownLoadPdfStarted extends DownLoadPdfState {}

final class PdfDownloadSuccess extends DownLoadPdfState {
  final String filePath;

  PdfDownloadSuccess(this.filePath);
}

final class PdfDownloadFailure extends DownLoadPdfState {
  final Failure failure;

  PdfDownloadFailure(this.failure);
}

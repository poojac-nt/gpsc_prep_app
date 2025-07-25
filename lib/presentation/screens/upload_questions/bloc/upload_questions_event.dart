part of 'upload_questions_bloc.dart';

@immutable
sealed class UploadQuestionsEvent {}

class UploadCsvAndInsert extends UploadQuestionsEvent {
  final bool isTestUpload;

  UploadCsvAndInsert({required this.isTestUpload});
}

class ResetUploadState extends UploadQuestionsEvent {}

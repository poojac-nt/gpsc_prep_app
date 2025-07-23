part of 'upload_questions_bloc.dart';

@immutable
sealed class UploadQuestionsEvent {}

class UploadCsvAndInsert extends UploadQuestionsEvent {}

class ResetUploadState extends UploadQuestionsEvent {}

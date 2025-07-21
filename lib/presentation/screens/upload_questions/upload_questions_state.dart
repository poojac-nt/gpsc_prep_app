part of 'upload_questions_bloc.dart';

@immutable
sealed class UploadQuestionsState {}

final class UploadQuestionsInitial extends UploadQuestionsState {}

class UploadFileInProgress extends UploadQuestionsState {}

class UploadFileSuccess extends UploadQuestionsState {
  final UploadResult result;

  UploadFileSuccess(this.result);
}

class UploadFileFailure extends UploadQuestionsState {
  final Failure failure;

  UploadFileFailure(this.failure);
}

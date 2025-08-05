part of 'upload_questions_bloc.dart';

@immutable
sealed class UploadQuestionsState {}

/// Initial state when nothing has happened yet
final class UploadQuestionsInitial extends UploadQuestionsState {}

/// While parsing the selected file (CSV/XLSX)
final class ParseFileInProgress extends UploadQuestionsState {}

/// Parsing complete and valid payload ready for review
final class ParseFileSuccess extends UploadQuestionsState {
  final List<Map<String, dynamic>> parsedPayload;
  final bool isTestUpload;

  ParseFileSuccess({required this.parsedPayload, required this.isTestUpload});
}

/// Parsing failed (invalid file, validation error, etc.)
final class ParseFileFailure extends UploadQuestionsState {
  final String errorMessage;

  ParseFileFailure(this.errorMessage);
}

/// While uploading parsed data to Supabase
final class UploadFileInProgress extends UploadQuestionsState {}

/// Upload completed successfully
final class UploadFileSuccess extends UploadQuestionsState {
  final UploadResult result;

  UploadFileSuccess(this.result);
}

/// Upload failed (e.g., Supabase RPC error)
final class UploadFileFailure extends UploadQuestionsState {
  final String errorMessage;

  UploadFileFailure(this.errorMessage);
}

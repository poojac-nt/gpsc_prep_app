part of 'upload_questions_bloc.dart';

@immutable
sealed class UploadQuestionsEvent {}

class ResetUploadState extends UploadQuestionsEvent {}

/// Triggers file selection + parsing (CSV/XLSX to List<Map>)
class ParseUploadFile extends UploadQuestionsEvent {
  final bool isTestUpload;

  ParseUploadFile({required this.isTestUpload});
}

/// Uploads the previously parsed payload to Supabase
class UploadParsedQuestionsToSupabase extends UploadQuestionsEvent {
  final List<Map<String, dynamic>> payload;
  final bool isTestUpload;

  UploadParsedQuestionsToSupabase({
    required this.payload,
    required this.isTestUpload,
  });
}

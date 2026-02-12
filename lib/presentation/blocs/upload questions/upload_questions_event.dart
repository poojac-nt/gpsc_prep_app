part of 'upload_questions_bloc.dart';

@immutable
sealed class UploadQuestionsEvent {}

class ResetUploadState extends UploadQuestionsEvent {}

/// Triggers file selection + parsing (CSV/XLSX to List<Map>)
class McqParseUploadFile extends UploadQuestionsEvent {
  final bool isTestUpload;

  McqParseUploadFile({required this.isTestUpload});
}

/// Uploads the previously parsed payload to Supabase
class McqUploadParsedQuestions extends UploadQuestionsEvent {
  final List<Map<String, dynamic>> payload;
  final bool isTestUpload;
  final DateTime? availableAt;

  McqUploadParsedQuestions({
    required this.payload,
    required this.isTestUpload,
    this.availableAt,
  });
}

class DescParseUploadFile extends UploadQuestionsEvent {}

/// Uploads the previously parsed payload to Supabase
class DescUploadParsedQuestions extends UploadQuestionsEvent {
  final List<Map<String, dynamic>> payload;

  DescUploadParsedQuestions({required this.payload});
}

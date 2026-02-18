part of 'upload_questions_bloc.dart';

@immutable
sealed class UploadQuestionsEvent {}

class ResetUploadState extends UploadQuestionsEvent {}

/// Triggers file selection + parsing (CSV/XLSX to List<Map>)
class McqParseUploadFile extends UploadQuestionsEvent {
  final bool isTestUpload;
  final int? courseId;

  McqParseUploadFile({required this.isTestUpload, this.courseId});
}

/// Uploads the previously parsed payload to Supabase
class McqUploadParsedQuestions extends UploadQuestionsEvent {
  final List<Map<String, dynamic>> payload;
  final bool isTestUpload;
  final DateTime? availableAt;
  final int? courseId;

  McqUploadParsedQuestions({
    required this.payload,
    required this.isTestUpload,
    this.availableAt,
    this.courseId,
  });
}

class DescParseUploadFile extends UploadQuestionsEvent {}

/// Uploads the previously parsed payload to Supabase
class DescUploadParsedQuestions extends UploadQuestionsEvent {
  final List<Map<String, dynamic>> payload;

  DescUploadParsedQuestions({required this.payload});
}

class FetchCoursesRequested extends UploadQuestionsEvent {}

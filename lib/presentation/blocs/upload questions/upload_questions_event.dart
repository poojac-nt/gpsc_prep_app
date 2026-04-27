part of 'upload_questions_bloc.dart';

@immutable
sealed class UploadQuestionsEvent {}

class ResetUploadState extends UploadQuestionsEvent {}

/// Triggers file selection + parsing (CSV/XLSX to List<Map>)
class McqParseUploadFile extends UploadQuestionsEvent {
  final bool isTestUpload;
  final int? courseId;
  final int? priceSingle;
  final int? priceDual;
  final CourseTestType? testType;

  McqParseUploadFile({
    required this.isTestUpload,
    this.courseId,
    this.priceSingle,
    this.priceDual,
    this.testType,
  });
}

/// Uploads the previously parsed payload to Supabase
class McqUploadParsedQuestions extends UploadQuestionsEvent {
  final List<Map<String, dynamic>> payload;
  final bool isTestUpload;
  final DateTime? availableAt;
  final int? courseId;
  final int? priceSingle;
  final int? priceDual;
  final CourseTestType? testType;

  McqUploadParsedQuestions({
    required this.payload,
    required this.isTestUpload,
    this.availableAt,
    this.courseId,
    this.priceSingle,
    this.priceDual,
    this.testType,
  });
}

class DescParseUploadFile extends UploadQuestionsEvent {
  final int? courseId;
  final int? priceSingle;
  final int? priceDual;
  final CourseTestType? testType;

  DescParseUploadFile({
    this.courseId,
    this.priceSingle,
    this.priceDual,
    this.testType,
  });
}

/// Uploads the previously parsed payload to Supabase
class DescUploadParsedQuestions extends UploadQuestionsEvent {
  final List<Map<String, dynamic>> payload;
  final int? courseId;
  final DateTime? availableAt;
  final int? priceSingle;
  final int? priceDual;
  final CourseTestType? testType;

  DescUploadParsedQuestions({
    required this.payload,
    this.courseId,
    this.availableAt,
    this.priceSingle,
    this.priceDual,
    this.testType,
  });
}

class FetchCoursesRequested extends UploadQuestionsEvent {}

class FetchProductsRequested extends UploadQuestionsEvent {}

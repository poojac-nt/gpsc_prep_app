part of 'upload_questions_bloc.dart';

@immutable
sealed class UploadQuestionsState {}

/// Initial state when nothing has happened yet
final class UploadQuestionsInitial extends UploadQuestionsState {}

/// While parsing the selected file (CSV/XLSX)
final class ParseFileInProgress extends UploadQuestionsState {}

/// Parsing complete and valid payload ready for review
final class McqParseFileSuccess extends UploadQuestionsState {
  final List<Map<String, dynamic>> parsedPayload;
  final bool isTestUpload;
  final int? courseId;
  final int? priceSingle;
  final int? priceDual;
  final CourseTestType? testType;

  McqParseFileSuccess({
    required this.parsedPayload,
    required this.isTestUpload,
    this.courseId,
    this.priceSingle,
    this.priceDual,
    this.testType,
  });
}

final class DescParseFileSuccess extends UploadQuestionsState {
  final List<Map<String, dynamic>> parsedPayload;
  final int? courseId;
  final int? priceSingle;
  final int? priceDual;
  final CourseTestType? testType;

  DescParseFileSuccess({
    required this.parsedPayload,
    this.courseId,
    this.priceSingle,
    this.priceDual,
    this.testType,
  });
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

class CoursesLoading extends UploadQuestionsState {}

class CoursesLoaded extends UploadQuestionsState {
  final List<CourseModel> courses;

  CoursesLoaded(this.courses);
}

class CoursesLoadFailure extends UploadQuestionsState {
  final String errorMessage;

  CoursesLoadFailure(this.errorMessage);
}

class ProductsLoading extends UploadQuestionsState {}

class ProductsLoaded extends UploadQuestionsState {
  final List<ProductModel> products;

  ProductsLoaded(this.products);
}

class ProductsLoadFailure extends UploadQuestionsState {
  final String errorMessage;

  ProductsLoadFailure(this.errorMessage);
}

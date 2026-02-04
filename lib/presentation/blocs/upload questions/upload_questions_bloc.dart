import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/upload_questions/desc_test_upload.dart';
import 'package:gpsc_prep_app/presentation/screens/upload_questions/upload_csv_service.dart';
import 'package:meta/meta.dart';

part 'upload_questions_event.dart';
part 'upload_questions_state.dart';

class UploadQuestionsBloc
    extends Bloc<UploadQuestionsEvent, UploadQuestionsState> {
  UploadQuestionsBloc() : super(UploadQuestionsInitial()) {
    on<ResetUploadState>((event, emit) {
      emit(UploadQuestionsInitial()); // or your initial state
    });
    on<McqParseUploadFile>(_onMcqParseUploadFile);
    on<McqUploadParsedQuestions>(_onMcqUploadParsedQuestions);
    on<DescParseUploadFile>(_onDescParseUploadFile);
    on<DescUploadParsedQuestions>(_onDescUploadParsedQuestions);
  }

  /// Handles parsing of the file (CSV/XLSX)
  Future<void> _onMcqParseUploadFile(
    McqParseUploadFile event,
    Emitter<UploadQuestionsState> emit,
  ) async {
    emit(ParseFileInProgress());

    try {
      final result = await parseUploadFile(isTestUpload: event.isTestUpload);

      result.fold(
        (failure) => emit(ParseFileFailure(failure.message)),
        (parsedPayload) => emit(
          McqParseFileSuccess(
            parsedPayload: parsedPayload,
            isTestUpload: event.isTestUpload,
          ),
        ),
      );
    } catch (e) {
      emit(ParseFileFailure('Failed to parse file: ${e.toString()}'));
    }
  }

  /// Handles final upload to Supabase
  Future<void> _onMcqUploadParsedQuestions(
    McqUploadParsedQuestions event,
    Emitter<UploadQuestionsState> emit,
  ) async {
    emit(UploadFileInProgress());

    try {
      final result = await submitParsedDataToSupabase(
        payload: event.payload,
        isTestUpload: event.isTestUpload,
      );

      result.fold(
        (failure) => emit(UploadFileFailure(failure.message)),
        (successResult) => emit(UploadFileSuccess(successResult)),
      );
    } catch (e) {
      emit(UploadFileFailure('❌ Upload failed: ${e.toString()}'));
    }
  }

  /// Handles parsing of the file (CSV/XLSX)
  Future<void> _onDescParseUploadFile(
    DescParseUploadFile event,
    Emitter<UploadQuestionsState> emit,
  ) async {
    emit(ParseFileInProgress());

    try {
      final result = await parseDescUploadFile();

      result.fold(
        (failure) => emit(ParseFileFailure(failure.message)),
        (parsedPayload) =>
            emit(DescParseFileSuccess(parsedPayload: parsedPayload)),
      );
    } catch (e) {
      emit(ParseFileFailure('Failed to parse file: ${e.toString()}'));
    }
  }

  /// Handles final upload to Supabase
  Future<void> _onDescUploadParsedQuestions(
    DescUploadParsedQuestions event,
    Emitter<UploadQuestionsState> emit,
  ) async {
    emit(UploadFileInProgress());

    try {
      final result = await submitDescTestToSupabase(payload: event.payload);

      result.fold(
        (failure) => emit(UploadFileFailure(failure.message)),
        (successResult) => emit(UploadFileSuccess(successResult)),
      );
    } catch (e) {
      emit(UploadFileFailure('❌ Upload failed: ${e.toString()}'));
    }
  }
}

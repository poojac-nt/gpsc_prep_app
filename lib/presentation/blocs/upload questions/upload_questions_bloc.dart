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
      final parsedPayload = await parseUploadFile(
        isTestUpload: event.isTestUpload,
      );

      if (parsedPayload == null) {
        emit(ParseFileFailure('Parsing returned null. Please check the file.'));
      } else {
        emit(
          McqParseFileSuccess(
            parsedPayload: parsedPayload,
            isTestUpload: event.isTestUpload,
          ),
        );
      }
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

      // 🚨 Handle null response case
      if (result == null) {
        // Since it's a known case for Daily Test uploads, check flags if needed
        if (event.isTestUpload) {
          emit(
            UploadFileFailure(
              'A daily test has already been uploaded today. Only one allowed per day.',
            ),
          );
        } else {
          emit(UploadFileFailure('❌ Upload failed: No response received.'));
        }
        return;
      }

      emit(UploadFileSuccess(result));
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains(
        'A Daily test has already been created today',
      )) {
        emit(
          UploadFileFailure(
            'A daily test has already been uploaded today. Only one allowed per day.',
          ),
        );
      } else {
        emit(UploadFileFailure('❌ Upload failed: $errorMessage'));
      }
    }
  }

  /// Handles parsing of the file (CSV/XLSX)
  Future<void> _onDescParseUploadFile(
    DescParseUploadFile event,
    Emitter<UploadQuestionsState> emit,
  ) async {
    emit(ParseFileInProgress());

    try {
      final parsedPayload = await parseDescUploadFile();

      if (parsedPayload == null) {
        emit(ParseFileFailure('Parsing returned null. Please check the file.'));
      } else {
        emit(DescParseFileSuccess(parsedPayload: parsedPayload));
      }
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

      // 🚨 Handle null response case
      if (result == null) {
        emit(UploadFileFailure('❌ Upload failed: No response received.'));
      }

      emit(UploadFileSuccess(result!));
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains(
        'A Daily test has already been created today',
      )) {
        emit(
          UploadFileFailure(
            'A daily test has already been uploaded today. Only one allowed per day.',
          ),
        );
      } else {
        emit(UploadFileFailure('❌ Upload failed: $errorMessage'));
      }
    }
  }
}

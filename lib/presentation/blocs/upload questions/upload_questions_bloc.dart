import 'package:bloc/bloc.dart';
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
    on<ParseUploadFile>(_onParseUploadFile);
    on<UploadParsedQuestionsToSupabase>(_onUploadParsedQuestionsToSupabase);
  }

  /// Handles parsing of the file (CSV/XLSX)
  Future<void> _onParseUploadFile(
    ParseUploadFile event,
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
          ParseFileSuccess(
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
  Future<void> _onUploadParsedQuestionsToSupabase(
    UploadParsedQuestionsToSupabase event,
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
}

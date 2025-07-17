import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/presentation/screens/upload_questions/upload_csv_service.dart';
import 'package:meta/meta.dart';

part 'upload_questions_event.dart';
part 'upload_questions_state.dart';

class UploadQuestionsBloc
    extends Bloc<UploadQuestionsEvent, UploadQuestionsState> {
  UploadQuestionsBloc() : super(UploadQuestionsInitial()) {
    on<UploadCsvAndInsert>(_onUploadCsvAndInsert);
    on<ResetUploadState>((event, emit) {
      emit(UploadQuestionsInitial()); // or your initial state
    });
  }

  Future<void> _onUploadCsvAndInsert(
    UploadCsvAndInsert event,
    Emitter<UploadQuestionsState> emit,
  ) async {
    emit(UploadFileInProgress());

    try {
      final result = await uploadCsvOrXlsxToSupabaseMobile();

      emit(UploadFileSuccess(result!));
    } catch (e) {
      emit(UploadFileFailure(Failure('Upload failed: ${e.toString()}')));
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/upload_questions/upload_csv_service.dart';
import 'package:meta/meta.dart';

part 'upload_questions_event.dart';
part 'upload_questions_state.dart';

class UploadQuestionsBloc
    extends Bloc<UploadQuestionsEvent, UploadQuestionsState> {
  UploadQuestionsBloc() : super(UploadQuestionsInitial()) {
    on<UploadQuestionsEvent>((event, emit) {
      on<UploadCsvAndInsert>(_onUploadCsvAndInsert);
    });
  }

  Future<void> _onUploadCsvAndInsert(
    UploadCsvAndInsert event,
    Emitter<UploadQuestionsState> emit,
  ) async {
    emit(UploadFileInProgress());

    try {
      final result = await uploadCsvAndInsertQuestions();

      emit(UploadFileSuccess(result));
    } catch (e) {
      emit(UploadFileFailure('Upload failed: ${e.toString()}'));
    }
  }
}

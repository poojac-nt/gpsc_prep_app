import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/models/payloads/course_payload.dart';
import 'package:gpsc_prep_app/data/repositories/course_repository.dart';
import 'package:gpsc_prep_app/domain/entities/course_model.dart';

part 'add_course_event.dart';
part 'add_course_state.dart';

class AddCourseBloc extends Bloc<AddCourseEvent, AddCourseState> {
  final CourseRepository _courseRepository;

  AddCourseBloc(this._courseRepository) : super(AddCourseInitial()) {
    on<AddCourseRequested>(_onAddCourseRequested);
  }

  Future<void> _onAddCourseRequested(
    AddCourseRequested event,
    Emitter<AddCourseState> emit,
  ) async {
    emit(AddCourseLoading());
    final result = await _courseRepository.createCourse(
      CoursePayload(name: event.name, description: event.description),
    );

    result.fold(
      (failure) => emit(AddCourseFailure(failure.message)),
      (course) => emit(AddCourseSuccess(course)),
    );
  }
}

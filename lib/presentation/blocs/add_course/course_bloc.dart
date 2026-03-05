import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/models/payloads/course_payload.dart';
import 'package:gpsc_prep_app/data/repositories/course_repository.dart';
import 'package:gpsc_prep_app/domain/entities/course_model.dart';

part 'course_event.dart';
part 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepository _courseRepository;

  CourseBloc(this._courseRepository) : super(CourseInitial()) {
    on<AddCourseRequested>(_onAddCourseRequested);
    on<FetchCoursesRequested>(_onFetchCoursesRequested);
  }

  Future<void> _onAddCourseRequested(
    AddCourseRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseLoading());
    final result = await _courseRepository.createCourse(
      CoursePayload(
        name: event.name,
        description: event.description,
        testType: event.testType,
        priceSingle: event.priceSingle,
        priceDual: event.priceDual,
      ),
    );

    result.fold(
      (failure) => emit(AddCourseFailure(failure.message)),
      (course) => emit(AddCourseSuccess(course)),
    );
  }

  Future<void> _onFetchCoursesRequested(
    FetchCoursesRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseLoading());
    final result = await _courseRepository.fetchCourses();

    result.fold(
      (failure) => emit(FetchCoursesFailure(failure.message)),
      (course) => emit(FetchCoursesSuccess(course)),
    );
  }
}

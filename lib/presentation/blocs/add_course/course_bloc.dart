import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/models/payloads/course_payload.dart';
import 'package:gpsc_prep_app/data/repositories/course_repository.dart';
import 'package:gpsc_prep_app/domain/entities/course_model.dart';
import 'package:gpsc_prep_app/domain/entities/product_model.dart';
import 'package:gpsc_prep_app/utils/enums/course_test_type.dart';
import 'package:meta/meta.dart';

part 'course_event.dart';

part 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepository _courseRepository;

  CourseBloc(this._courseRepository) : super(CourseInitial()) {
    on<AddCourseRequested>(_onAddCourseRequested);
    on<FetchCoursesRequested>(_onFetchCoursesRequested);
    on<ToggleCourseStatusRequested>(_onToggleCourseStatusRequested);
    on<FetchProductsRequested>(_onFetchProductsRequested);
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
    final result = await _courseRepository.fetchCourses(isAdmin: event.isAdmin);

    result.fold(
      (failure) => emit(FetchCoursesFailure(failure.message)),
      (course) => emit(FetchCoursesSuccess(course)),
    );
  }

  Future<void> _onFetchProductsRequested(
    FetchProductsRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseLoading());
    final result = await _courseRepository.fetchProducts();

    result.fold(
      (failure) => emit(FetchProductsFailure(failure.message)),
      (products) => emit(FetchProductsSuccess(products)),
    );
  }

  Future<void> _onToggleCourseStatusRequested(
    ToggleCourseStatusRequested event,
    Emitter<CourseState> emit,
  ) async {
    emit(CourseStatusUpdateLoading());
    final result = await _courseRepository.toggleCourseActive(
      courseId: event.courseId,
      isActive: event.isActive,
    );

    result.fold(
      (failure) => emit(CourseStatusUpdateFailure(failure.message)),
      (_) => emit(CourseStatusUpdateSuccess(event.courseId, event.isActive)),
    );
  }
}

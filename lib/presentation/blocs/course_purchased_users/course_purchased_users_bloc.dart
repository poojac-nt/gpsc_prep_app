import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/data/repositories/course_repository.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';

part 'course_purchased_users_event.dart';

part 'course_purchased_users_state.dart';

class CoursePurchasedUsersBloc
    extends Bloc<CoursePurchasedUsersEvent, CoursePurchasedUsersState> {
  final CourseRepository _courseRepository;

  CoursePurchasedUsersBloc(this._courseRepository)
    : super(CoursePurchasedUsersInitial()) {
    on<FetchCoursePurchasedUsers>(_onFetchCoursePurchasedUsers);
  }

  Future<void> _onFetchCoursePurchasedUsers(
    FetchCoursePurchasedUsers event,
    Emitter<CoursePurchasedUsersState> emit,
  ) async {
    emit(CoursePurchasedUsersLoading());
    final result = await _courseRepository.fetchCoursePurchasedUsers(
      event.courseId,
    );

    result.fold(
      (failure) => emit(CoursePurchasedUsersError(failure)),
      (users) => emit(CoursePurchasedUsersLoaded(users)),
    );
  }
}

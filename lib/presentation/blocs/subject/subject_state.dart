part of 'subject_bloc.dart';

@immutable
sealed class SubjectState {}

final class SubjectInitial extends SubjectState {}

final class SubjectLoading extends SubjectState {}

final class SubjectSuccess extends SubjectState {
  final List<SubjectModel> subjects;
  SubjectSuccess(this.subjects);
}

final class SubjectFailure extends SubjectState {
  final String message;
  SubjectFailure(this.message);
}

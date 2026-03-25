part of 'pending_submissions_bloc.dart';

@immutable
sealed class PendingSubmissionsEvent {}

class FetchPendingSubmissions extends PendingSubmissionsEvent {}

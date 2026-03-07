import 'package:flutter/foundation.dart';
import 'package:gpsc_prep_app/domain/entities/pending_submission.dart';

@immutable
sealed class PendingSubmissionsState {}

final class PendingSubmissionsInitial extends PendingSubmissionsState {}

final class PendingSubmissionsLoading extends PendingSubmissionsState {}

final class PendingSubmissionsLoaded extends PendingSubmissionsState {
  final List<PendingSubmission> pendingSubmissions;
  PendingSubmissionsLoaded(this.pendingSubmissions);
}

final class PendingSubmissionsError extends PendingSubmissionsState {
  final String message;
  PendingSubmissionsError(this.message);
}

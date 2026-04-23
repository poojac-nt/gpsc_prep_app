import 'package:equatable/equatable.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/domain/entities/all_tests_model.dart';
import 'package:gpsc_prep_app/domain/entities/notification_model.dart';

enum NotificationStatus {
  initial,
  loadingMetadata,
  metadataLoaded,
  metadataError,
  submitting,
  success,
  error,
  loadingHistory,
  historyLoaded,
  historyError,
}

class NotificationState extends Equatable {
  final NotificationStatus status;
  final AllTestsModel? metadata;
  final Failure? failure;
  final List<NotificationModel> notifications;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.metadata,
    this.failure,
    this.notifications = const [],
  });

  NotificationState copyWith({
    NotificationStatus? status,
    AllTestsModel? metadata,
    Failure? failure,
    List<NotificationModel>? notifications,
  }) {
    return NotificationState(
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      failure: failure ?? this.failure,
      notifications: notifications ?? this.notifications,
    );
  }

  @override
  List<Object?> get props => [status, metadata, failure, notifications];
}

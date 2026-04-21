import 'package:equatable/equatable.dart';
import 'package:gpsc_prep_app/core/error/failure.dart';
import 'package:gpsc_prep_app/domain/entities/all_tests_model.dart';

enum NotificationStatus { initial, loadingMetadata, metadataLoaded, metadataError, submitting, success, error }

class NotificationState extends Equatable {
  final NotificationStatus status;
  final AllTestsModel? metadata;
  final Failure? failure;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.metadata,
    this.failure,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    AllTestsModel? metadata,
    Failure? failure,
  }) {
    return NotificationState(
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, metadata, failure];
}

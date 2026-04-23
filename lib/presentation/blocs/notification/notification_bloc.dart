import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpsc_prep_app/data/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  NotificationBloc(this._repository) : super(const NotificationState()) {
    on<FetchNotificationMetadata>(_onFetchMetadata);
    on<FetchNotificationHistory>(_onFetchHistory);
    on<CreateNotificationEvent>(_onCreateNotification);
    on<UpdateNotificationEvent>(_onUpdateNotification);
  }

  Future<void> _onFetchMetadata(
    FetchNotificationMetadata event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.loadingMetadata));
    final result = await _repository.getNotificationMetadata();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotificationStatus.metadataError,
          failure: failure,
        ),
      ),
      (metadata) => emit(
        state.copyWith(
          status: NotificationStatus.metadataLoaded,
          metadata: metadata,
        ),
      ),
    );
  }

  Future<void> _onFetchHistory(
    FetchNotificationHistory event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.loadingHistory));
    final result = await _repository.fetchNotifications();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotificationStatus.historyError,
          failure: failure,
        ),
      ),
      (notifications) => emit(
        state.copyWith(
          status: NotificationStatus.historyLoaded,
          notifications: notifications,
        ),
      ),
    );
  }

  Future<void> _onCreateNotification(
    CreateNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.submitting));
    final result = await _repository.createNotification(event.notification);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotificationStatus.error,
          failure: failure,
        ),
      ),
      (notification) => emit(
        state.copyWith(status: NotificationStatus.success),
      ),
    );
  }

  Future<void> _onUpdateNotification(
    UpdateNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.submitting));
    final result = await _repository.updateNotification(event.notification);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotificationStatus.error,
          failure: failure,
        ),
      ),
      (_) => emit(state.copyWith(status: NotificationStatus.success)),
    );
  }
}

import 'package:equatable/equatable.dart';
import 'package:gpsc_prep_app/domain/entities/notification_model.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotificationMetadata extends NotificationEvent {}

class FetchNotificationHistory extends NotificationEvent {}

class CreateNotificationEvent extends NotificationEvent {
  final NotificationModel notification;
  const CreateNotificationEvent(this.notification);

  @override
  List<Object?> get props => [notification];
}

class UpdateNotificationEvent extends NotificationEvent {
  final NotificationModel notification;
  const UpdateNotificationEvent(this.notification);

  @override
  List<Object?> get props => [notification];
}

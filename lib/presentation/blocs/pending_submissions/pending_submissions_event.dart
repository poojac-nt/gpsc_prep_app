import 'package:flutter/foundation.dart';

@immutable
sealed class PendingSubmissionsEvent {}

class FetchPendingSubmissions extends PendingSubmissionsEvent {}

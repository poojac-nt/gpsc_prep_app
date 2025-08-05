import 'package:flutter/material.dart';

@immutable
sealed class DashboardBlocEvent {}

class FetchAttemptedTests extends DashboardBlocEvent {}

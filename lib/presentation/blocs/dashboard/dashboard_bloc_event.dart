import 'package:flutter/material.dart';

@immutable
sealed class DashboardBlocEvent {}

class DashBoardInitial extends DashboardBlocEvent {}

class FetchDashboardAnalytics extends DashboardBlocEvent {}

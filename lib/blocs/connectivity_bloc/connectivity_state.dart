part of 'connectivity_bloc.dart';

@immutable
sealed class ConnectivityState {}

final class ConnectivityInitial extends ConnectivityState {}

final class ConnectivityOnline extends ConnectivityState {}

final class ConnectivityOffline extends ConnectivityState {}

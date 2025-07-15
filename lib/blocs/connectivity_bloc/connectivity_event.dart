part of 'connectivity_bloc.dart';

@immutable
sealed class ConnectivityEvent {}

class CheckConnectivity extends ConnectivityEvent {}

class ResetConnectivity extends ConnectivityEvent {}

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/data/repositories/authentiction_repository.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/auth_bloc.dart';

final getIt = GetIt.instance;
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void setupInitializer() {
  setupHelpers();
  setupRepositories();
  setupBlocs();
}

void setupHelpers() {
  getIt.registerLazySingleton<LogHelper>(LogHelper.new);

  getIt.registerLazySingleton<SupabaseHelper>(
    () => SupabaseHelper(getIt<LogHelper>()),
  );

  getIt.registerLazySingleton<SnackBarHelper>(
    () => SnackBarHelper(scaffoldMessengerKey),
  );
}

void setupRepositories() {
  getIt.registerLazySingleton<AuthenticationRepository>(
    () => AuthenticationRepository(getIt<SupabaseHelper>()),
  );
}

void setupBlocs() {
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(getIt<SupabaseHelper>()),
  );
}

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/shared_prefs_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/data/repositories/authentiction_repository.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/auth_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/profile/edit_profile_bloc.dart';

import '../../presentation/screens/test_module/bloc/test_bloc.dart';

final getIt = GetIt.instance;
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void setupInitializer() {
  setupHelpers();
  setupRepositories();
  setupBlocs();
}

void setupHelpers() {
  getIt.registerLazySingleton<SharedPrefHelper>(SharedPrefHelper.new);
  getIt.registerLazySingleton<LogHelper>(LogHelper.new);

  getIt.registerLazySingleton<SupabaseHelper>(
    () => SupabaseHelper(getIt<LogHelper>()),
  );

  getIt.registerLazySingleton<CacheManager>(
    () => CacheManager(getIt<SharedPrefHelper>()),
  );

  getIt.registerLazySingleton<SnackBarHelper>(
    () => SnackBarHelper(scaffoldMessengerKey),
  );
}

void setupRepositories() {
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<SupabaseHelper>()),
  );
}

void setupBlocs() {
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(getIt<AuthRepository>(), getIt<CacheManager>()),
  );
  getIt.registerLazySingleton<EditProfileBloc>(
    () => EditProfileBloc(
      getIt<CacheManager>(),
      getIt<AuthRepository>(),
      getIt<SnackBarHelper>(),
      getIt<CacheManager>(),
      getIt<LogHelper>(),
    ),
  );
  getIt.registerLazySingleton<QuestionBloc>(() => QuestionBloc());
}

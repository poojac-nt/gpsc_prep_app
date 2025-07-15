import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:gpsc_prep_app/blocs/connectivity_bloc/connectivity_bloc.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/helpers/log_helper.dart';
import 'package:gpsc_prep_app/core/helpers/shared_prefs_helper.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/data/repositories/authentiction_repository.dart';
import 'package:gpsc_prep_app/data/repositories/test_repository.dart';
import 'package:gpsc_prep_app/domain/entities/result_model.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/auth_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/profile/edit_profile_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test/bloc/daily_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/question/question_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test/test_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/timer/timer_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/cubit/test/test_cubit.dart';
import 'package:gpsc_prep_app/presentation/screens/upload_questions/upload_questions_bloc.dart';
import 'package:hive_flutter/adapters.dart';

import '../../presentation/screens/test_module/cubit/question/question_cubit.dart';

final getIt = GetIt.instance;
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void setupInitializer() {
  setupHelpers();
  setupRepositories();
  setupBlocs();
  setUpHive();
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

  getIt.registerLazySingleton<TestRepository>(
    () => TestRepository(getIt<SupabaseHelper>()),
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
      getIt<LogHelper>(),
    ),
  );
  getIt.registerLazySingleton<QuestionBloc>(
    () => QuestionBloc(getIt<TestRepository>()),
  );
  getIt.registerLazySingleton<TestBloc>(
    () => TestBloc(getIt<TestRepository>()),
  );
  getIt.registerLazySingleton<UploadQuestionsBloc>(() => UploadQuestionsBloc());
  getIt.registerLazySingleton<TimerBloc>(() => TimerBloc());
  getIt.registerLazySingleton<DailyTestBloc>(
    () => DailyTestBloc(getIt<TestRepository>()),
  );
  getIt.registerLazySingleton<TestCubit>(() => TestCubit());
  getIt.registerLazySingleton<QuestionCubit>(() => QuestionCubit());
  getIt.registerLazySingleton<ConnectivityBloc>(() => ConnectivityBloc());
}

Future<void> setUpHive() async {
  // Init Hive
  await Hive.initFlutter();
  // Register Hive adapters
  Hive.registerAdapter(TestResultModelAdapter());
  // Open Hive box and register it
  final testResultBox = await Hive.openBox<TestResultModel>('test_results');
  getIt.registerSingleton<Box<TestResultModel>>(testResultBox);
}

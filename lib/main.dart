import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/app/app.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/shared_prefs_helper.dart';
import 'package:gpsc_prep_app/core/router/app_routes.dart';
import 'package:gpsc_prep_app/domain/entities/user_model.dart';
import 'package:gpsc_prep_app/presentation/screens/auth/auth_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/profile/edit_profile_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test/bloc/daily_test_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/test_event.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/timer/timer_bloc.dart';
import 'package:gpsc_prep_app/presentation/screens/test_module/bloc/timer/timer_event.dart';
import 'package:gpsc_prep_app/presentation/screens/upload_questions/upload_questions_bloc.dart';
import 'package:gpsc_prep_app/utils/constants/secrets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await ScreenUtil.ensureScreenSize();

  await Supabase.initialize(
    url: AppSecrets.apiUrl,
    anonKey: AppSecrets.serviceKey,
  );

  setupInitializer();

  await getIt<SharedPrefHelper>().init();

  final cacheManager = getIt<CacheManager>();
  final UserModel? user = await cacheManager.getInitUser();
  AppRouter.init(user != null);

  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<AuthBloc>()),
          BlocProvider(
            create: (_) => getIt<QuestionBloc>()..add(LoadQuestion()),
          ),
          BlocProvider(create: (_) => getIt<EditProfileBloc>()),
          BlocProvider(create: (_) => getIt<UploadQuestionsBloc>()),
          BlocProvider(
            create: (_) => getIt<QuestionBloc>()..add(LoadQuestion()),
          ),
          BlocProvider(create: (_) => getIt<TimerBloc>()),
          BlocProvider(create: (_) => getIt<DailyTestBloc>()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

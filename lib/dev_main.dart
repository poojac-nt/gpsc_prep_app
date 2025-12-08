import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gpsc_prep_app/app/app.dart';
import 'package:gpsc_prep_app/app_services.dart';

import 'config/environment.dart';

Future<void> main() async {
  Environment.setFlavor(Flavor.development);
  await AppServices().appInit();
  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MultiBlocProvider(
        providers: AppServices().blocProviders,
        child: SafeArea(top: false, bottom: true, child: const MyApp()),
      ),
    ),
  );
}

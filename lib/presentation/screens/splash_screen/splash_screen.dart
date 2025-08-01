import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/core/cache_manager.dart';
import 'package:gpsc_prep_app/core/di/di.dart';
import 'package:gpsc_prep_app/core/helpers/snack_bar_helper.dart';
import 'package:gpsc_prep_app/core/helpers/supabase_helper.dart';
import 'package:gpsc_prep_app/presentation/blocs/connectivity_bloc/connectivity_bloc.dart';
import 'package:gpsc_prep_app/presentation/widgets/connectivity_handler_dialog.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';
import 'package:gpsc_prep_app/utils/enums/user_role.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _initializationStarted = false;

  @override
  void initState() {
    super.initState();

    // Start listening to connectivity changes
    context.read<ConnectivityBloc>().add(CheckConnectivity());
  }

  void _startInitializationIfOnline() {
    if (_initializationStarted) return;

    final state = context.read<ConnectivityBloc>().state;
    if (state is ConnectivityOnline) {
      _initializationStarted = true;
      _initializeApp();
    }
  }

  Future<void> _initializeApp() async {
    final needsUpdate = await _checkAppVersion();
    if (needsUpdate) return;

    await _setupFirebaseMessaging();
    _navigateBasedOnUserRole();
  }

  Future<bool> _checkAppVersion() async {
    try {
      final status = await getIt<SupabaseHelper>().appVersionCheck();
      if (status == AppVersionStatus.needsUpdate) {
        _showForceUpdateDialog();
        return true;
      }
    } catch (e) {
      debugPrint("App version check failed: $e");
      getIt<SnackBarHelper>().showError("Failed to check app version.");
    }
    return false;
  }

  Future<void> _setupFirebaseMessaging() async {
    try {
      await FirebaseMessaging.instance.requestPermission();

      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await _setFcmToken(fcmToken);
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        await _setFcmToken(token);
      });

      FirebaseMessaging.onMessage.listen((payload) {
        final notification = payload.notification;
        if (notification != null) {
          getIt<SnackBarHelper>().showSuccess(notification.body ?? "");
        }
      });
    } catch (e) {
      debugPrint("Firebase setup failed: $e");
      getIt<SnackBarHelper>().showError("Firebase setup failed.");
    }
  }

  Future<void> _setFcmToken(String token) async {
    await getIt<SupabaseHelper>().updateOrInsertFcmToken(token);
  }

  void _navigateBasedOnUserRole() {
    final role = getIt<CacheManager>().getUserRole();
    switch (role) {
      case UserRole.student:
        context.go(AppRoutes.studentDashboard);
        break;
      case UserRole.mentor:
        context.go(AppRoutes.mentorDashboard);
        break;
      case UserRole.admin:
        context.go(AppRoutes.studentDashboard);
        break;
      default:
        context.go(AppRoutes.login);
    }
  }

  void _showForceUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text('Update Required'),
            content: const Text(
              'Your app version is outdated. Please update to continue using the app.',
            ),
            actions: [
              TextButton(
                onPressed: _launchAppStore,
                child: const Text('Update Now'),
              ),
            ],
          ),
    );
  }

  void _launchAppStore() async {
    const url = "https://play.google.com/store/apps/details?id=app.starics";
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      getIt<SnackBarHelper>().showError('Unable to open the app store.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ConnectivityBloc, ConnectivityState>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, state) {
          if (state is ConnectivityOffline) {
            ConnectivityDialogHelper.showOfflineDialog(context);
          } else if (state is ConnectivityOnline) {
            ConnectivityDialogHelper.dismissDialog(context);
            _startInitializationIfOnline(); // ✅ Start logic only when online
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_without_bg.png',
                height: 230.h,
                width: 230.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

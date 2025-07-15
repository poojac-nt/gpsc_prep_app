import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gpsc_prep_app/utils/app_constants.dart';

class ConnectivityDialogHelper {
  static bool _isDialogVisible = false;

  // Define excluded routes by path
  static final List<String> _excludedRoutes = [
    AppRoutes.resultScreen,
    AppRoutes.testScreen,
  ];

  static void showOfflineDialog(BuildContext context) {
    final currentLocation = GoRouter.of(context).state.matchedLocation;

    if (_excludedRoutes.any(
          (excluded) => currentLocation.startsWith(excluded),
        ) ||
        _isDialogVisible) {
      return;
    }

    _isDialogVisible = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => WillPopScope(
              onWillPop: () async => false,
              child: const AlertDialog(
                title: Text("No Internet Connection"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text("You're offline. Please wait for reconnection."),
                  ],
                ),
              ),
            ),
      );
    });
  }

  static void dismissDialog(BuildContext context) {
    if (_isDialogVisible &&
        Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
      _isDialogVisible = false;
    }
  }
}

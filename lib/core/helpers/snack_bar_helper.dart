import 'package:flutter/material.dart';

class SnackBarHelper {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  SnackBarHelper(this.scaffoldMessengerKey);

  void showError(String message) {
    _hideAndShowSnackBar(
      message,
      backgroundColor: Colors.red.shade300,
      duration: const Duration(seconds: 3),
    );
  }

  void showSuccess(String message) {
    _hideAndShowSnackBar(
      message,
      backgroundColor: Colors.green.shade300,
      duration: const Duration(seconds: 2),
    );
  }

  void _hideAndShowSnackBar(
    String message, {
    required Color backgroundColor,
    required Duration duration,
  }) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) {
      return;
    }

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }
}

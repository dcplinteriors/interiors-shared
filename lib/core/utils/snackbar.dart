import 'package:flutter/material.dart';

/// Global messenger key wired into `MaterialApp.router` — lets us show snackbars
/// from anywhere (controllers, dialogs) without a BuildContext. Used instead of
/// `Get.snackbar`, which doesn't work under a router-based app.
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void showAppSnackbar(String message) {
  rootScaffoldMessengerKey.currentState
    ?..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));
}

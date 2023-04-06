import 'package:flutter/material.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback? didPause;
  final VoidCallback? didTerminate;

  AppLifecycleObserver({
    this.didPause,
    this.didTerminate,
  });

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        didPause?.call();
        break;
      case AppLifecycleState.detached:
        didTerminate?.call();
        break;
      default:
        break;
    }
  }
}

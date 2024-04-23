import 'dart:isolate';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaper_app/configs/sf_keys.dart';

Future<bool> grantedForegroundServicePermissionsAndroid() async {
  final NotificationPermission notificationPermissionStatus =
      await FlutterForegroundTask.checkNotificationPermission();

  if (notificationPermissionStatus != NotificationPermission.granted) {
    await FlutterForegroundTask.requestNotificationPermission();

    if (notificationPermissionStatus == NotificationPermission.granted) {
      return true;
    }
    return false;
  }
  return true;
}

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
}

class FirstTaskHandler extends TaskHandler {
  int _eventCount = 0;

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    sendPort?.send('changeWallpaper');
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    final value = await SharedPreferences.getInstance();

    final newInterval = value.getInt(intervalKey) ?? 0;

    if (_eventCount >= newInterval) {
      sendPort?.send('changeWallpaper');
      _eventCount = 0;
    } else {
      final timeLeft = newInterval - _eventCount;

      FlutterForegroundTask.updateService(
          notificationText: "Auto change is enabled - $newInterval minute(s) interval",
          notificationTitle: "Wallpaper - ${timeLeft - 1} minutes(s) left");

      _eventCount++;
    }
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {}
}

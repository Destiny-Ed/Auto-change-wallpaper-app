import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/models/android_notification_options.dart';
import 'package:flutter_foreground_task/models/foreground_task_options.dart';
import 'package:flutter_foreground_task/models/ios_notification_options.dart';
import 'package:flutter_foreground_task/models/notification_channel_importance.dart';
import 'package:flutter_foreground_task/models/notification_icon_data.dart';
import 'package:flutter_foreground_task/models/notification_priority.dart';
import 'package:flutter_foreground_task/ui/will_start_foreground_task.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaper_app/configs/app_logger.dart';
import 'package:wallpaper_app/configs/sf_keys.dart';
import 'package:wallpaper_app/shared/services/foreground_service.dart';
import 'package:wallpaper_app/src/admin/provider/admin_provider.dart';
import 'package:wallpaper_app/src/authentication/provider/auth.dart';
import 'package:wallpaper_app/configs/routers.dart';
import 'package:wallpaper_app/firebase_options.dart';
import 'package:wallpaper_app/src/category/provider/category_provider.dart';
import 'package:wallpaper_app/src/downloads/provider/download_provider.dart';
import 'package:wallpaper_app/src/favourite/provider/provider.dart';
import 'package:wallpaper_app/src/home/provider/home_wallpaper_provider.dart';
import 'package:wallpaper_app/src/onboarding/provider/state_provider.dart';
import 'package:wallpaper_app/src/search/provider/search_provider.dart';
import 'package:wallpaper_app/src/settings/provider/settings_provider.dart';
import 'package:wallpaper_app/styles/color.dart';
import 'package:wallpaper_app/src/root_screen/provider/root_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => OnboardingProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => AdminProvider()),
        ChangeNotifierProvider(create: (context) => WallPaperProvider()),
        ChangeNotifierProvider(create: (context) => SearchProvider()),
        ChangeNotifierProvider(create: (context) => FavoriteProvider()),
        ChangeNotifierProvider(create: (context) => DownloadProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: WillStartForegroundTask(
        onWillStart: () async {
          final value = await SharedPreferences.getInstance();

          final newInterval = value.getInt(intervalKey) ?? 0;

          if (newInterval < 1) {
            return false;
          }

          // Return whether to start the foreground service.
          return await grantedForegroundServicePermissionsAndroid();
        },
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'foreground_service_1',
          channelName: 'Foreground Service Notification',
          channelDescription: 'This notification appears when the foreground service is running.',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
          isSticky: false, // important
          iconData: const NotificationIconData(
            resType: ResourceType.mipmap,
            resPrefix: ResourcePrefix.ic,
            name: 'launcher',
          ),
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: true,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          interval: const Duration(minutes: 1).inMilliseconds,
          isOnceEvent: false,
          allowWakeLock: false,
          allowWifiLock: false,
        ),
        notificationTitle: 'Auto changer is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
        onData: _onData,
        child: MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
                centerTitle: true,
                scrolledUnderElevation: 0,
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(color: white)),
            scaffoldBackgroundColor: black,
            primaryColor: primaryColor,
          ),
        ),
      ),
    );
  }

  void _onData(dynamic data) async {
    if (data is String) {
      if (data == 'changeWallpaper') {
        await SettingsProvider().autoChangeWallpaper();
      }
    }
  }
}

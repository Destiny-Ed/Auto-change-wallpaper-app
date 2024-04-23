import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaper_app/configs/app_logger.dart';
import 'package:wallpaper_app/configs/sf_keys.dart';

abstract class _Settings {
  Future<void> setAutoChangeInterval(Duration interval);
  Future<int> getAutoChangeInterval();
  Future<bool> autoChangeWallpaper();
  Future<void> setWallpaperLocation(int location);
  Future<int> getWallpaperLocation();
  Future<List<String>> getAutoChangeWallpapersList();
  Future<void> saveAutoChangeWallpaper(List<String> images);
  Future<void> getAppVersion();
}

class SettingsProvider extends ChangeNotifier implements _Settings {
  final _appPref = SharedPreferences.getInstance();

  List<Duration> getIntervalList() {
    return List.generate(10, (index) => Duration(minutes: 1 * (index + 1)));
  }

  List<int> wallpaperLocationList = [
    WallpaperManager.HOME_SCREEN,
    WallpaperManager.LOCK_SCREEN,
    WallpaperManager.BOTH_SCREEN
  ];

  String returnLocationNameFromInt(int location) {
    String text;
    switch (location) {
      case 1:
        text = 'Home';
      case 2:
        text = 'Lock';
      case 3:
        text = 'Both';
      default:
        text = 'Home';
    }
    return text;
  }

  Duration _selectedDuration = const Duration(minutes: 0);
  Duration get selectedDuration => _selectedDuration;

  int _selectedWallpaperLocation = WallpaperManager.HOME_SCREEN;
  int get selectedWallpaperLocation => _selectedWallpaperLocation;

  String _appVersion = '';
  String get appVersion => _appVersion;

  List<String> _autoChangeWallpaperList = [];
  List<String> get autoChangeWallpaperList => _autoChangeWallpaperList;
  set setChangeWallpaperValue(String image) {
    if (_autoChangeWallpaperList.contains(image)) {
      //remove
      _autoChangeWallpaperList.remove(image);
    } else {
      //add
      _autoChangeWallpaperList.add(image);
    }
    _updateState();
  }

  void _updateState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  @override
  Future<bool> autoChangeWallpaper() async {
    final interval = await getAutoChangeInterval();

    final location = await getWallpaperLocation();

    appLogger("Interval and location : $interval, $location");

    final downloadFiles = await getAutoChangeWallpapersList();

    if (downloadFiles.isNotEmpty) {
      final rand = Random().nextInt(downloadFiles.length);

      await WallpaperManager.setWallpaperFromFile(downloadFiles[rand], location);

      appLogger("Wallpaper applied successfully");
      return true;
    }

    return false;
  }

  @override
  Future<void> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    _appVersion = packageInfo.version;

    _updateState();
  }

  @override
  Future<int> getAutoChangeInterval() async {
    final value = await _appPref;
    final interval = value.getInt(intervalKey) ?? 0;

    _selectedDuration = Duration(minutes: interval);

    _updateState();

    return interval;
  }

  @override
  Future<List<String>> getAutoChangeWallpapersList() async {
    final value = await _appPref;

    final list = value.getStringList(autoChangeWallpapersKey) ?? [];

    _autoChangeWallpaperList = list;

    _updateState();

    return list;
  }

  @override
  Future<int> getWallpaperLocation() async {
    final value = await _appPref;
    final location = value.getInt(wallpaperLocationKey) ?? WallpaperManager.HOME_SCREEN;

    _selectedWallpaperLocation = location;

    _updateState();

    return location;
  }

  @override
  Future<void> saveAutoChangeWallpaper(List<String> images) async {
    final value = await _appPref;

    value.setStringList(autoChangeWallpapersKey, images);

    getAutoChangeWallpapersList();
  }

  @override
  Future<void> setAutoChangeInterval(Duration interval) async {
    final value = await _appPref;

    value.setInt(intervalKey, interval.inMinutes);

    getAutoChangeInterval();
  }

  @override
  Future<void> setWallpaperLocation(int location) async {
    final value = await _appPref;

    value.setInt(wallpaperLocationKey, location);

    getWallpaperLocation();
  }
}

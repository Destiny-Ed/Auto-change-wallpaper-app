import 'package:flutter/material.dart';
import 'package:wallpaper_app/src/admin/screens/admin_home.dart';
import 'package:wallpaper_app/src/category/screens/category_screen.dart';
import 'package:wallpaper_app/src/favourite/screens/favorite_screen.dart';
import 'package:wallpaper_app/src/home/screen/home_screen.dart';
import 'package:wallpaper_app/src/settings/screens/settings_screen.dart';

class HomeProvider extends ChangeNotifier {
  int _index = 0;
  int get index => _index;
  set setIndex(int value) {
    _index = value;
    notifyListeners();
  }

  List<Map> bottomNavItems = [
    {"label": "Home", "icon": Icons.home},
    {"label": "Category", "icon": Icons.category},
    {"label": "Favourite", "icon": Icons.favorite},
    {"label": "Settings", "icon": Icons.settings},
    {"label": "Admin", "icon": Icons.admin_panel_settings},
  ];

  List<Widget> bottomNavPages = [
    const HomeScreen(),
    const CategoryScreen(),
    const FavoriteScreen(),
    const SettingsScreen(),
    const AdminHomeScreen()
  ];
}

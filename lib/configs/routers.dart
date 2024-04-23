import 'package:go_router/go_router.dart';
import 'package:wallpaper_app/src/admin/screens/add_category.dart';
import 'package:wallpaper_app/src/admin/screens/add_wallpaper.dart';
import 'package:wallpaper_app/src/admin/screens/my_gallery.dart';
import 'package:wallpaper_app/src/category/screens/category_screen.dart';
import 'package:wallpaper_app/src/category/screens/view_category_screen.dart';
import 'package:wallpaper_app/src/downloads/screen/downloads_screen.dart';
import 'package:wallpaper_app/src/home/screen/view_wallpaper_screen.dart';
import 'package:wallpaper_app/src/onboarding/screens/onboarding_home.dart';
import 'package:wallpaper_app/splash_screen.dart';
import 'package:wallpaper_app/src/root_screen/screens/root_screen.dart';
import 'package:wallpaper_app/src/search/screen/seach_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/on_boarding',
      builder: (context, state) => const OnboardingHome(),
    ),
    GoRoute(
      path: '/root',
      builder: (context, state) => const RootScreen(),
    ),
    GoRoute(
      path: '/add_category',
      builder: (context, state) => const AddCategoryScreen(),
    ),
    GoRoute(
      path: '/add_wallpaper',
      builder: (context, state) => const AddWallpaperScreen(),
    ),
    GoRoute(
      path: '/category',
      builder: (context, state) {
        final isAdmin = (state.extra as Map)['is_admin'];
        return CategoryScreen(
          isAdmin: isAdmin,
        );
      },
    ),
    GoRoute(
      path: '/view_category',
      builder: (context, state) {
        final data = (state.extra as Map);
        return CategoryViewScreen(
          categoryName: data['category_name'],
        );
      },
    ),
    GoRoute(
      path: '/search_screen',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/downloads',
      builder: (context, state) {
        final isAutoChangeSelection = (state.extra ?? false) as bool;
        return DownloadScreen(
          isAutoChangeSelection: isAutoChangeSelection,
        );
      },
    ),
    GoRoute(
      path: '/view_wallpaper',
      builder: (context, state) {
        final data = state.extra as Map;
        return ViewWallPaperScreen(
          url: data['wallpaper_url'],
          categoryName: data['category_name'] ?? '',
          wallpaperId: data['wallpaper_id'],
          showFavouriteIcon: data['show_icon'],
          isLocalFile: data['is_local_file'] ?? false,
        );
      },
    ),
    GoRoute(
      path: '/gallery',
      builder: (context, state) => const MyGallery(),
    ),
  ],
);

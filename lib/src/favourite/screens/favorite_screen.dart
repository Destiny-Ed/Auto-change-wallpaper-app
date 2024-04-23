import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_app/configs/enums.dart';
import 'package:wallpaper_app/shared/dialog/message_dialog.dart';
import 'package:wallpaper_app/shared/widgets/busy_overlay.dart';
import 'package:wallpaper_app/shared/widgets/empty_widget.dart';
import 'package:wallpaper_app/shared/widgets/wallpaper_widget.dart';
import 'package:wallpaper_app/src/favourite/provider/provider.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();
    _viewFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(builder: (context, favState, child) {
      return BusyOverlay(
        show: favState.viewState == ViewState.busy,
        child: Scaffold(
          body: (favState.favoriteList.isEmpty && favState.viewState == ViewState.success)
              ? const EmtpyWidget(title: 'No Recent Favourite')
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GridView(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 0.6, crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10),
                    children: List.generate(favState.favoriteList.length, (index) {
                      final data = favState.favoriteList[index];
                      return WallpaperWidget(
                        url: data.wallpaperImage,
                        onTap: () async {
                          final payload = {
                            "wallpaper_url": data.wallpaperImage,
                            "show_icon": true,
                            "wallpaper_id": data.id,
                          };

                          await context.push('/view_wallpaper', extra: payload);

                          _viewFavorite();
                        },
                      );
                    }),
                  ),
                ),
        ),
      );
    });
  }

  void _viewFavorite() async {
    final providerState = Provider.of<FavoriteProvider>(context, listen: false);

    await providerState.retrieveFavourite();

    if (providerState.viewState == ViewState.error) {
      if (mounted) {
        showMessage(context, providerState.message);
        return;
      }
    }
  }
}

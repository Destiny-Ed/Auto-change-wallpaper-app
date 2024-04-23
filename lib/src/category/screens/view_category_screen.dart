import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_app/configs/enums.dart';
import 'package:wallpaper_app/shared/dialog/message_dialog.dart';
import 'package:wallpaper_app/shared/widgets/busy_overlay.dart';
import 'package:wallpaper_app/shared/widgets/empty_widget.dart';
import 'package:wallpaper_app/shared/widgets/wallpaper_widget.dart';
import 'package:wallpaper_app/src/home/provider/home_wallpaper_provider.dart';
import 'package:wallpaper_app/styles/color.dart';

class CategoryViewScreen extends StatefulWidget {
  final String categoryName;
  const CategoryViewScreen({super.key, required this.categoryName});

  @override
  State<CategoryViewScreen> createState() => _CategoryViewScreenState();
}

class _CategoryViewScreenState extends State<CategoryViewScreen> {
  @override
  void initState() {
    super.initState();
    _viewCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WallPaperProvider>(builder: (context, state, child) {
      return BusyOverlay(
        show: state.viewState == ViewState.busy,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: Text(
              widget.categoryName,
              style: const TextStyle(color: white, fontWeight: FontWeight.bold),
            ),
          ),
          body: (state.categoryWallpapers.isEmpty && state.viewState == ViewState.success)
              ? const EmtpyWidget(title: 'No category wallpaper')
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GridView(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 0.6, crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10),
                    children: List.generate(state.categoryWallpapers.length, (index) {
                      final data = state.categoryWallpapers[index];
                      return WallpaperWidget(
                        url: data.wallPaperImage,
                        onTap: () {
                          final payload = {
                            "wallpaper_url": data.wallPaperImage,
                            "show_icon": true,
                            "wallpaper_id": data.wallpaperId,
                            "category_name": data.categoryName
                          };

                          context.push('/view_wallpaper', extra: payload);
                        },
                      );
                    }),
                  ),
                ),
        ),
      );
    });
  }

  void _viewCategory() async {
    final providerState = Provider.of<WallPaperProvider>(context, listen: false);

    await providerState.fetchWallpaperByCategory(widget.categoryName);

    if (providerState.viewState == ViewState.error) {
      if (mounted) {
        showMessage(context, providerState.message);
        return;
      }
    }
  }
}

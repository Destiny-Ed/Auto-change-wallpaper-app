import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_app/configs/enums.dart';
import 'package:wallpaper_app/shared/widgets/empty_widget.dart';
import 'package:wallpaper_app/shared/widgets/wallpaper_widget.dart';
import 'package:wallpaper_app/src/admin/provider/admin_provider.dart';
import 'package:wallpaper_app/styles/color.dart';

class MyGallery extends StatefulWidget {
  const MyGallery({super.key});

  @override
  State<MyGallery> createState() => _MyGalleryState();
}

class _MyGalleryState extends State<MyGallery> {
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();

    _scrollController.addListener(_scrollListener);

    Provider.of<AdminProvider>(context, listen: false).getPaginatedAdminWallPaper();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(builder: (context, state, child) {
      return Scaffold(
        appBar: AppBar(),
        body: (state.adminWallpaper.isEmpty && state.viewState == ViewState.success)
            ? const EmtpyWidget(title: 'No Gallery wallpaper')
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: Stack(
                  children: [
                    GridView(
                      controller: _scrollController,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 0.6,
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10),
                      children: List.generate(state.adminWallpaper.length, (index) {
                        final data = state.adminWallpaper[index];
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
                    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: const Text(
                            "Fetching more data...",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      );
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      Provider.of<AdminProvider>(context, listen: false).getPaginatedAdminWallPaper();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
}

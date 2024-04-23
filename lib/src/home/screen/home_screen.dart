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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _viewWallpaper();
  }

  bool _isEnd = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<WallPaperProvider>(builder: (context, state, child) {
      return BusyOverlay(
        show: state.viewState == ViewState.busy && state.recentWallpapers.isEmpty,
        child: Scaffold(
            body: (state.recentWallpapers.isEmpty && state.viewState == ViewState.success)
                ? const EmtpyWidget(title: 'No recent wallpaper')
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.pixels == notification.metrics.maxScrollExtent) {
                          _isEnd = true;
                          _viewWallpaper();
                        } else {
                          _isEnd = false;
                        }
                        setState(() {});
                        return true;
                      },
                      child: Stack(
                        children: [
                          RefreshIndicator(
                            onRefresh: () {
                              _viewWallpaper(isRefresh: true);
                              return Future.delayed(const Duration(seconds: 2));
                            },
                            child: GridView(
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 0.6,
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10),
                              children: List.generate(state.recentWallpapers.length, (index) {
                                final data = state.recentWallpapers[index];
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
                          if (_isEnd)
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
                  )),
      );
    });
  }

  void _viewWallpaper({bool isRefresh = false}) async {
    final providerState = Provider.of<WallPaperProvider>(context, listen: false);

    await providerState.fetchRecentPaginatedWallpaper(isRefresh);

    // if (providerState.viewState == ViewState.error) {
    //   if (mounted) {
    //     showMessage(context, providerState.message);
    //     return;
    //   }
    // }
  }
}

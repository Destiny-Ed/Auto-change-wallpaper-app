import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_app/configs/enums.dart';
import 'package:wallpaper_app/configs/extensions.dart';
import 'package:wallpaper_app/shared/dialog/apply_bottom_sheet.dart';
import 'package:wallpaper_app/shared/dialog/message_dialog.dart';
import 'package:wallpaper_app/shared/widgets/busy_overlay.dart';
import 'package:wallpaper_app/src/downloads/provider/download_provider.dart';
import 'package:wallpaper_app/src/favourite/model/model.dart';
import 'package:wallpaper_app/src/favourite/provider/provider.dart';
import 'package:wallpaper_app/src/home/provider/home_wallpaper_provider.dart';
import 'package:wallpaper_app/styles/color.dart';

class ViewWallPaperScreen extends StatefulWidget {
  final String url;
  final String wallpaperId;
  final String categoryName;
  final bool isLocalFile;
  final bool showFavouriteIcon;
  const ViewWallPaperScreen(
      {super.key,
      required this.url,
      required this.wallpaperId,
      required this.categoryName,
      this.showFavouriteIcon = false,
      this.isLocalFile = false});

  @override
  State<ViewWallPaperScreen> createState() => _ViewWallPaperScreenState();
}

class _ViewWallPaperScreenState extends State<ViewWallPaperScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.isLocalFile) {
      Provider.of<FavoriteProvider>(context, listen: false).retrieveFavouriteById(widget.wallpaperId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<FavoriteProvider, DownloadProvider, WallPaperProvider>(
        builder: (context, favState, downloadState, wallpaperState, child) {
      return BusyOverlay(
        show: downloadState.viewState == ViewState.busy || wallpaperState.viewState == ViewState.busy,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              widget.categoryName,
              style: const TextStyle(color: white),
            ),
            actions: [
              if (!widget.isLocalFile)
                IconButton(
                  onPressed: () {
                    if (favState.isFavourite) {
                      favState.deleteFromFavourite(widget.wallpaperId);
                    } else {
                      favState.addToFavourite(FavoriteModel(
                          id: widget.wallpaperId,
                          wallpaperImage: widget.url,
                          dateCreated: DateTime.now().millisecondsSinceEpoch));
                    }
                  },
                  icon: Icon(
                    favState.isFavourite ? Icons.favorite : Icons.favorite_border,
                    color: favState.isFavourite ? primaryColor : white,
                  ),
                )
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: widget.isLocalFile
                      ? FileImage(File(widget.url))
                      : CachedNetworkImageProvider(widget.url) as ImageProvider,
                  fit: BoxFit.cover),
            ),
            child: Stack(
              children: [
                Positioned(
                    bottom: 50,
                    left: 30,
                    right: 30,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(primaryColor),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: const BorderSide(color: white)))),
                            onPressed: () {
                              if (Platform.isIOS) {
                                _downloadIOSFile(downloadState);
                                return;
                              }

                              showApplyBottomSheet(
                                context,
                                onHomeTapped: () {
                                  _applyWallpaper(
                                      WallpaperManager.HOME_SCREEN, downloadState, wallpaperState);
                                },
                                onLockTapped: () {
                                  _applyWallpaper(
                                      WallpaperManager.LOCK_SCREEN, downloadState, wallpaperState);
                                },
                                onBothTapped: () {
                                  _applyWallpaper(
                                      WallpaperManager.BOTH_SCREEN, downloadState, wallpaperState);
                                },
                              );

                              ///show modal
                            },
                            child: const Text(
                              'Apply Wallpaper',
                              style: TextStyle(color: white),
                            ),
                          ),
                        ),
                        20.width(),
                        if (!widget.isLocalFile)
                          FloatingActionButton(
                            backgroundColor: white,
                            onPressed: () async {
                              await downloadState.downloadFile(widget.url);

                              if (downloadState.viewState == ViewState.error) {
                                if (context.mounted) {
                                  showMessage(context, downloadState.message);
                                  return;
                                }
                              }

                              if (downloadState.viewState == ViewState.success) {
                                if (context.mounted) {
                                  showMessage(
                                      context, "File downloaded successfully. Go to app downloads to see it",
                                      onConfirmTapped: () {
                                    context.push('/downloads');
                                  }, isError: false);
                                  return;
                                }
                              }
                            },
                            mini: true,
                            child: const Icon(
                              Icons.download,
                              color: primaryColor,
                            ),
                          )
                      ],
                    ))
              ],
            ),
          ),
        ),
      );
    });
  }

  void _applyWallpaper(int location, DownloadProvider downloadState, WallPaperProvider wallPaperState) async {
    if (!widget.isLocalFile) {
      await downloadState.downloadFile(widget.url);

      if (downloadState.viewState == ViewState.error) {
        if (mounted) {
          showMessage(context, downloadState.message);
          return;
        }
      }
    }

    await wallPaperState.applyWallpaper(widget.isLocalFile ? widget.url : downloadState.message, location);

    if (wallPaperState.viewState == ViewState.error) {
      if (mounted) {
        showMessage(context, wallPaperState.message);
        return;
      }
    }

    if (wallPaperState.viewState == ViewState.success) {
      if (mounted) {
        showMessage(context, wallPaperState.message, isError: false);
        return;
      }
    }
  }

  void _downloadIOSFile(DownloadProvider downloadState) async {
    if (widget.isLocalFile) {
      await downloadState.saveFileInExternalStorage(File(widget.url));
    } else {
      await downloadState.downloadFile(widget.url);
    }

    //
    if (downloadState.viewState == ViewState.error) {
      if (mounted) {
        showMessage(context, downloadState.message);
        return;
      }
    }

    if (downloadState.viewState == ViewState.success) {
      if (mounted) {
        showMessage(context, downloadState.message, isError: false);
        return;
      }
    }
  }
}

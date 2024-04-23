import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_app/configs/enums.dart';
import 'package:wallpaper_app/shared/dialog/message_dialog.dart';
import 'package:wallpaper_app/shared/widgets/busy_overlay.dart';
import 'package:wallpaper_app/shared/widgets/empty_widget.dart';
import 'package:wallpaper_app/shared/widgets/wallpaper_widget.dart';
import 'package:wallpaper_app/src/downloads/provider/download_provider.dart';
import 'package:wallpaper_app/src/settings/provider/settings_provider.dart';
import 'package:wallpaper_app/styles/color.dart';

class DownloadScreen extends StatefulWidget {
  final bool isAutoChangeSelection;
  const DownloadScreen({super.key, this.isAutoChangeSelection = false});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  @override
  void initState() {
    super.initState();
    _viewDownloads();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DownloadProvider, SettingsProvider>(
        builder: (context, downloadState, settingState, child) {
      return BusyOverlay(
        show: downloadState.viewState == ViewState.busy,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Downloads',
              style: TextStyle(color: white),
            ),
          ),
          body: (downloadState.downloadedFiles.isEmpty && downloadState.viewState == ViewState.success)
              ? const EmtpyWidget(title: 'No Recent Downloads')
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GridView(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 0.6, crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10),
                    children: List.generate(downloadState.downloadedFiles.length, (index) {
                      final data = downloadState.downloadedFiles[index];
                      return Stack(
                        children: [
                          WallpaperWidget(
                            url: data.path,
                            isLocal: true,
                            onTap: () async {
                              if (widget.isAutoChangeSelection) {
                                settingState.setChangeWallpaperValue = data.path;
                              } else {
                                final url = {
                                  "wallpaper_url": data.path,
                                  "show_icon": true,
                                  "is_local_file": true,
                                  "wallpaper_id": ''
                                };
                                await context.push('/view_wallpaper', extra: url);
                              }
                            },
                          ),
                          if (widget.isAutoChangeSelection &&
                              settingState.autoChangeWallpaperList.contains(data.path))
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: primaryColor, borderRadius: BorderRadius.circular(10)),
                                child: const Text(
                                  'Auto Change Enabled',
                                  style: TextStyle(color: white),
                                ),
                              ),
                            )
                        ],
                      );
                    }),
                  ),
                ),
        ),
      );
    });
  }

  void _viewDownloads() async {
    final providerState = Provider.of<DownloadProvider>(context, listen: false);

    await providerState.getDownloadedFiles();

    if (providerState.viewState == ViewState.error) {
      if (mounted) {
        showMessage(context, providerState.message);
        return;
      }
    }
  }
}

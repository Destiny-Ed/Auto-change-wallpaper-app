import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_app/configs/app_logger.dart';
import 'package:wallpaper_app/configs/enums.dart';
import 'package:wallpaper_app/shared/utils/convert_url_to_file.dart';

abstract class _Download {
  Future<void> downloadFile(String url);
  Future<void> saveFileInExternalStorage(File file);
  Future<List<File>> getDownloadedFiles();
}

class DownloadProvider extends ChangeNotifier implements _Download {
  ViewState viewState = ViewState.idle;
  String message = "";

  List<File> _downloadedFiles = [];
  List<File> get downloadedFiles => _downloadedFiles;

  void _updateState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  @override
  Future<void> downloadFile(String url) async {
    viewState = ViewState.busy;
    _updateState();

    try {
      final fileResponse = await converUrlToFile(url);

      if (fileResponse == null) {
        viewState = ViewState.error;
        message = "Please try again";
        _updateState();
        return;
      }

      ///save file into local storage
      await saveFileInExternalStorage(fileResponse);

      viewState = ViewState.success;
      message = fileResponse.path;
      _updateState();
    } catch (e) {
      message = 'Please try again';
      viewState = ViewState.error;
      _updateState();
    }
  }

  @override
  Future<List<File>> getDownloadedFiles() async {
    viewState = ViewState.busy;
    _updateState();

    try {
      final appDir = await getApplicationDocumentsDirectory();

      final directory = Directory(appDir.path);

      final files = await directory.list().toList();

      //filter out files only (exclude directories)

      final fileList = files.whereType<File>().toList();

      _downloadedFiles = fileList;
      viewState = ViewState.success;
      _updateState();

      return fileList;
    } catch (e) {
      message = 'Please try again';
      viewState = ViewState.error;
      _updateState();
      return [];
    }
  }

  @override
  Future<void> saveFileInExternalStorage(File file) async {
    final result = await ImageGallerySaver.saveImage(await file.readAsBytes());

    appLogger("Save file path ${file.path}");
    appLogger("Save file response $result");

    if (!result['isSuccess']) {
      viewState = ViewState.error;
      message = "Error downloading wallpaper. Try again";
      _updateState();
      return;
    }

    if (Platform.isIOS) {
      viewState = ViewState.success;
      message =
          "Wallpaper saved to your photos\n\nUnfortunately, you can't directly set the wallpaper from the app. \n\nGo to your photos and set wallpaper manually";
      _updateState();
      return;
    }
  }
}

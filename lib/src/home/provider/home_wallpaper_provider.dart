import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:wallpaper_app/configs/app_logger.dart';
import 'package:wallpaper_app/configs/enums.dart';
import 'package:wallpaper_app/src/home/model/wallpaper_model.dart';

abstract class _WallPaper {
  Future<void> fetchRecentPaginatedWallpaper(bool isReFresh);
  Future<void> fetchWallpaperByCategory(String categoryName);
  Future<void> applyWallpaper(String image, int location); //1, 2, 3
}

class WallPaperProvider extends ChangeNotifier implements _WallPaper {
  final List<WallpaperModel> _recentWallpapers = [];
  List<WallpaperModel> get recentWallpapers => _recentWallpapers;

  List<WallpaperModel> _categoryWallpapers = [];
  List<WallpaperModel> get categoryWallpapers => _categoryWallpapers;

  final _wallpaperRef = FirebaseFirestore.instance.collection('wallpaper');

  ViewState viewState = ViewState.idle;
  String message = "";

  void _updateState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  DocumentSnapshot? _lastDocument;
  DocumentSnapshot? get lastDocument => _lastDocument;
  set setDocument(DocumentSnapshot? doc) {
    _lastDocument = doc;
    _updateState();
  }

  @override
  Future<void> applyWallpaper(String image, int location) async {
    viewState = ViewState.busy;
    message = 'Applying wallpaper';
    _updateState();

    try {
      final result = await WallpaperManager.setWallpaperFromFile(image, location);

      appLogger("Wallpaper response $result");

      if (!result) {
        viewState = ViewState.error;
        message = "Error applying wallpaper. Try again";
        _updateState();
        return;
      }
      viewState = ViewState.success;
      message = "Wallpaper applied successfully.";
      _updateState();
    } catch (e) {
      message = "Please try again";
      viewState = ViewState.error;
      _updateState();
    }
  }

  @override
  Future<void> fetchRecentPaginatedWallpaper(bool isReFresh) async {
    viewState = ViewState.busy;
    _updateState();

    if (isReFresh) {
      _recentWallpapers.clear();
    }

    QuerySnapshot<Map<String, dynamic>> result;

    try {
      if (_recentWallpapers.isEmpty) {
        result = await _wallpaperRef.orderBy('date_created', descending: true).limit(10).get();
      } else {
        result = await _wallpaperRef
            .orderBy('date_created', descending: true)
            .startAfterDocument(_lastDocument!)
            .limit(10)
            .get();
      }

      if (result.docs.isNotEmpty) {
        for (var i in result.docs) {
          final data = WallpaperModel.fromJson(i.data());
          appLogger(data.toJson());
          data.wallpaperId = i.id;

          final isExists = _recentWallpapers.any((element) => element.wallpaperId == i.id);

          if (!isExists) {
            _recentWallpapers.add(data);
          }
        }
      }

      setDocument = result.docs.last;
      viewState = ViewState.success;
      _updateState();
    } on FirebaseException catch (e) {
      message = e.code;
      viewState = ViewState.error;
      _updateState();
    } catch (e) {
      message = e.toString();
      viewState = ViewState.error;
      _updateState();
    }
  }

  @override
  Future<void> fetchWallpaperByCategory(String categoryName) async {
    viewState = ViewState.busy;
    _updateState();

    try {
      final result = await _wallpaperRef.where('category_name', isEqualTo: categoryName.toLowerCase()).get();

      List<WallpaperModel> tempList = [];

      if (result.docs.isNotEmpty) {
        for (var i in result.docs) {
          final data = WallpaperModel.fromJson(i.data());

          data.wallpaperId = i.id;
          tempList.add(data);
        }
      }

      _categoryWallpapers = tempList;
      _categoryWallpapers.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));

      viewState = ViewState.success;
      _updateState();
    } on FirebaseException catch (e) {
      message = e.code;
      viewState = ViewState.error;
      _updateState();
    } catch (e) {
      message = e.toString();
      viewState = ViewState.error;
      _updateState();
    }
  }
}

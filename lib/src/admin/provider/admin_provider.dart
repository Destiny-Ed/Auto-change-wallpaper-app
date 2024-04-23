import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallpaper_app/configs/app_logger.dart';
import 'package:wallpaper_app/src/category/models/category_model.dart';
import 'package:wallpaper_app/configs/enums.dart';
import 'package:wallpaper_app/src/home/model/wallpaper_model.dart';
import 'package:wallpaper_app/shared/utils/upload_file.dart';

abstract class _Admin {
  Future<void> saveWallpaper();
  Future<void> saveCategory();
  Future<void> getPaginatedAdminWallPaper();
}

class AdminProvider extends ChangeNotifier implements _Admin {
  String _categoryName = '';
  String get categoryName => _categoryName;
  set categoryName(String value) {
    _categoryName = value;
    _updateState();
  }

  String? _categoryImage;
  String? get categoryImage => _categoryImage;
  set categoryImage(String? value) {
    _categoryImage = value;
    _updateState();
  }

  String _selectedCategory = '';
  String get selectedCategory => _selectedCategory;
  set selectedCategory(String value) {
    _selectedCategory = value;
    _updateState();
  }

  String? _wallpaperImage;
  String? get wallpaperImage => _wallpaperImage;
  set wallpaperImage(String? value) {
    _wallpaperImage = value;
    _updateState();
  }

  final List<String> _wallpaperTags = [];
  List<String> get wallpaperTags => _wallpaperTags;
  void setWallPaperTags(String value) {
    final lwValue = value.toLowerCase();
    if (!wallpaperTags.contains(lwValue)) {
      _wallpaperTags.add(lwValue);
    }
    _updateState();
  }

  void removeWallPaperTags(String value) {
    final lwValue = value.toLowerCase();

    if (wallpaperTags.contains(lwValue)) {
      _wallpaperTags.remove(lwValue);
    }
    _updateState();
  }

  void _updateState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  List<String> adminActionList = ["Add Category", "Add Wallpaper", "My Gallery"];

  final _categoryRef = FirebaseFirestore.instance.collection('category');
  final _wallpaperRef = FirebaseFirestore.instance.collection('wallpaper');

  final User? _user = FirebaseAuth.instance.currentUser;

  ViewState viewState = ViewState.idle;
  String message = "";

  final List<WallpaperModel> _adminWallpaper = [];
  List<WallpaperModel> get adminWallpaper => _adminWallpaper;

  DocumentSnapshot? _lastDocument;
  DocumentSnapshot? get lastDocument => _lastDocument;
  set setDocument(DocumentSnapshot? doc) {
    _lastDocument = doc;
    _updateState();
  }

  @override
  Future<void> saveCategory() async {
    viewState = ViewState.busy;
    _updateState();

    try {
      final urlString = await uploadDocumentToServer(_categoryImage!);

      if (urlString.state == ViewState.error) {
        viewState = ViewState.error;
        message = urlString.fileUrl;
        _updateState();
        return;
      }
      //success upload
      final payload = CategoryModel(
          categoryName: _categoryName,
          categoryImage: urlString.fileUrl,
          dateCreated: DateTime.now().millisecondsSinceEpoch);

      _categoryRef.add(payload.toJson());

      //clear values
      _categoryName = '';
      _categoryImage = null;

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
  Future<void> saveWallpaper() async {
    viewState = ViewState.busy;
    _updateState();

    try {
      final urlString = await uploadDocumentToServer(_wallpaperImage!);

      if (urlString.state == ViewState.error) {
        viewState = ViewState.error;
        message = urlString.fileUrl;
        _updateState();
        return;
      }
      //success upload
      final payload = WallpaperModel(
        wallpaperId: '',
        categoryName: _selectedCategory.toLowerCase(),
        wallPaperImage: urlString.fileUrl,
        wallPaperTags: _wallpaperTags,
        dateCreated: DateTime.now().millisecondsSinceEpoch,
        authorId: _user!.uid,
        author: Author(name: _user.displayName!, uid: _user.uid, email: _user.email!),
      );

      _wallpaperRef.add(payload.toJson());

      //clear values
      _selectedCategory = '';
      _wallpaperImage = null;
      wallpaperTags.clear();

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
  Future<void> getPaginatedAdminWallPaper() async {
    viewState = ViewState.busy;
    _updateState();

    QuerySnapshot<Map<String, dynamic>> result;

    try {
      if (_adminWallpaper.isEmpty) {
        result = await _wallpaperRef
            .where('author_id', isEqualTo: _user!.uid)
            .orderBy('date_created', descending: true)
            .limit(10)
            .get();
      } else {
        result = await _wallpaperRef
            .where('author_id', isEqualTo: _user!.uid)
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

          final isExists = _adminWallpaper.any((element) => element.wallpaperId == i.id);

          if (!isExists) {
            _adminWallpaper.add(data);
          }
        }
      }

      setDocument = result.docs.last;
      viewState = ViewState.success;
      notifyListeners();
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

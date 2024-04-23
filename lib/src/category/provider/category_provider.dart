import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wallpaper_app/src/category/models/category_model.dart';
import 'package:wallpaper_app/configs/enums.dart';

abstract class _Category {
  Future<void> fetchCategory();
}

class CategoryProvider extends ChangeNotifier implements _Category {
  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  final _categoryRef = FirebaseFirestore.instance.collection('category');

  ViewState viewState = ViewState.idle;
  String message = "";

  @override
  Future<void> fetchCategory() async {
    if (_categories.isEmpty) {
      viewState = ViewState.busy;
      _updateState();
    }

    try {
      final result = await _categoryRef.get();

      List<CategoryModel> tempList = [];

      if (result.docs.isNotEmpty) {
        for (var i in result.docs) {
          tempList.add(CategoryModel.fromJson(i.data()));
        }
      }

      _categories = tempList;

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

  void _updateState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}

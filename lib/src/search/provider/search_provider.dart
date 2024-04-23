import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wallpaper_app/configs/enums.dart';
import 'package:wallpaper_app/src/search/model/search_model.dart';

abstract class _Search {
  Future<void> search(String query);
}

class SearchProvider extends ChangeNotifier implements _Search {
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    _searchQuery = value;
    _updateState();
  }

  List<SearchModel> _searchResults = [];
  List<SearchModel> get searchResults => _searchResults;

  List<String> sampleSearches = ['love', 'animal', 'cool', 'car', 'dark', 'natural', 'fashion', 'beauty'];

  void _updateState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  ViewState viewState = ViewState.idle;
  String message = '';

  final _searchRef = FirebaseFirestore.instance.collection('wallpaper');

  @override
  Future<void> search(String query) async {
    viewState = ViewState.busy;
    _updateState();

    final lwQuery = query.toLowerCase();

    try {
      final result = await _searchRef.get();

      List<SearchModel> tempList = [];

      if (result.docs.isNotEmpty) {
        for (var i in result.docs) {
          final data = SearchModel.fromJson(i.data());
          data.wallpaperId = i.id;

          ///query
          if (data.categoryName.toLowerCase().contains(lwQuery) || data.wallPaperTags.contains(lwQuery)) {
            tempList.add(data);
          }
        }
      } else {
        tempList = [];
      }

      _searchResults = tempList;

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

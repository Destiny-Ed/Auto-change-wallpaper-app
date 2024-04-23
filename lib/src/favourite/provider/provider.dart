import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallpaper_app/configs/enums.dart';
import 'package:wallpaper_app/src/favourite/model/model.dart';

abstract class _Favourite {
  Future<void> addToFavourite(FavoriteModel data);
  Future<void> deleteFromFavourite(String id);
  Future<void> retrieveFavouriteById(String id);
  Future<void> retrieveFavourite();
}

class FavoriteProvider extends ChangeNotifier implements _Favourite {
  bool _isFavourite = false;
  bool get isFavourite => _isFavourite;
  set isFavourite(bool value) {
    _isFavourite = value;
    _updateState();
  }

  List<FavoriteModel> _favoriteList = [];
  List<FavoriteModel> get favoriteList => _favoriteList;

  ViewState viewState = ViewState.idle;
  String message = '';

  final _favouriteRef = FirebaseFirestore.instance.collection('favourites');
  final User? _user = FirebaseAuth.instance.currentUser;

  _updateState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
  }

  @override
  Future<void> addToFavourite(FavoriteModel data) async {
    _isFavourite = true;
    _updateState();
    await _favouriteRef.doc(_user?.uid).collection('data').add(data.toJson());
  }

  @override
  Future<void> deleteFromFavourite(String id) async {
    _isFavourite = false;
    _updateState();
    final result = await _favouriteRef.doc(_user?.uid).collection('data').where('id', isEqualTo: id).get();

    if (result.docs.isNotEmpty) {
      for (var i in result.docs) {
        await _favouriteRef.doc(_user?.uid).collection('data').doc(i.id).delete();
      }
    }
  }

  @override
  Future<void> retrieveFavourite() async {
    viewState = ViewState.busy;
    _updateState();

    try {
      final result = await _favouriteRef.doc(_user?.uid).collection('data').get();

      List<FavoriteModel> tempList = [];

      if (result.docs.isNotEmpty) {
        for (var i in result.docs) {
          tempList.add(FavoriteModel.fromJson(i.data()));
        }
      }

      _favoriteList = tempList;

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
  Future<void> retrieveFavouriteById(String id) async {
    final result = await _favouriteRef.doc(_user?.uid).collection('data').where('id', isEqualTo: id).get();

    _isFavourite = false;

    if (result.docs.isNotEmpty) {
      _isFavourite = true;
    }
    notifyListeners();
  }
}

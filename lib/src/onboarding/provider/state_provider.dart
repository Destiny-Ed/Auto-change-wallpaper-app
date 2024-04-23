import 'package:flutter/material.dart';
import 'package:wallpaper_app/src/onboarding/model/data_model.dart';

class OnboardingProvider extends ChangeNotifier {
  int _index = 0;
  int get index => _index;
  set index(int value) {
    _index = value;
    notifyListeners();
  }

  ///onboarding data
  final onboardingData = [
    OnboardingDataModel(
        image: ImagePathModel(imagePath: 'assets/image_one.jpeg', isAsset: true),
        title: 'View daily 4K wallpapers'),
    OnboardingDataModel(
        image: ImagePathModel(imagePath: 'assets/image2.jpeg', isAsset: true),
        title: 'Apply different wallpapers from different categories'),
    OnboardingDataModel(
        image: ImagePathModel(imagePath: 'assets/image3.jpeg', isAsset: true),
        title: 'Auto change wallpaper every minute'),
  ];
}

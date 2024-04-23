class OnboardingDataModel {
  final ImagePathModel image;
  final String title;

  OnboardingDataModel({required this.image, required this.title});
}



class ImagePathModel {
  final String imagePath;
  final bool isAsset;

  ImagePathModel({required this.imagePath, this.isAsset = true});
}

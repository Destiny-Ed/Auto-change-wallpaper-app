class FavoriteModel {
  String id;
  String wallpaperImage;
  int dateCreated;

  FavoriteModel({
    required this.id,
    required this.wallpaperImage,
    required this.dateCreated,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) => FavoriteModel(
        id: json["id"],
        wallpaperImage: json["wallpaper_image"],
        dateCreated: json["date_created"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "wallpaper_image": wallpaperImage,
        "date_created": dateCreated,
      };
}

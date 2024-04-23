class SearchModel {
  String wallpaperId;
  String categoryName;
  String wallPaperImage;
  List<String> wallPaperTags;
  int dateCreated;

  SearchModel({
    required this.wallpaperId,
    required this.categoryName,
    required this.wallPaperImage,
    required this.wallPaperTags,
    required this.dateCreated,
  });

  factory SearchModel.fromJson(Map<String, dynamic> json) => SearchModel(
        wallpaperId: json['wallpaper_id'],
        categoryName: json["category_name"],
        wallPaperImage: json["wallpaper_image"],
        wallPaperTags: List<String>.from(json["wallpaper_tags"].map((x) => x)),
        dateCreated: json["date_created"],
      );

  Map<String, dynamic> toJson() => {
        "wallpaper_id": wallpaperId,
        "category_name": categoryName,
        "wallpaper_image": wallPaperImage,
        "wallpaper_tags": List<dynamic>.from(wallPaperTags.map((x) => x)),
        "date_created": dateCreated,
      };
}

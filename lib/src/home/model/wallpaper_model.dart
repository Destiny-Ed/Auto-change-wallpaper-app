class WallpaperModel {
  String wallpaperId;
  String categoryName;
  String wallPaperImage;
  List<String> wallPaperTags;
  int dateCreated;
  String authorId;
  Author author;

  WallpaperModel({
    required this.wallpaperId,
    required this.categoryName,
    required this.wallPaperImage,
    required this.wallPaperTags,
    required this.dateCreated,
    required this.author,
    required this.authorId,
  });

  factory WallpaperModel.fromJson(Map<String, dynamic> json) => WallpaperModel(
        wallpaperId: json['wallpaper_id'],
        categoryName: json["category_name"],
        wallPaperImage: json["wall_paper_image"],
        wallPaperTags: List<String>.from(json["wall_paper_tags"].map((x) => x)),
        dateCreated: json["date_created"],
        authorId: json["author_id"],
        author: Author.fromJson(json["author"]),
      );

  Map<String, dynamic> toJson() => {
        "wallpaper_id": wallpaperId,
        "category_name": categoryName,
        "wall_paper_image": wallPaperImage,
        "wall_paper_tags": List<dynamic>.from(wallPaperTags.map((x) => x)),
        "date_created": dateCreated,
        "author_id": authorId,
        "author": author.toJson(),
      };
}

class Author {
  String name;
  String email;
  String uid;

  Author({required this.name, required this.uid, required this.email});

  factory Author.fromJson(Map<String, dynamic> json) => Author(
        name: json["name"],
        email: json["email"],
        uid: json["uid"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "uid": uid,
      };
}

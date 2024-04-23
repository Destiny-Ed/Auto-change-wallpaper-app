class CategoryModel {
  String categoryName;
  String categoryImage;
  int dateCreated;

  CategoryModel({
    required this.categoryName,
    required this.categoryImage,
    required this.dateCreated,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        categoryName: json["category_name"],
        categoryImage: json["category_image"],
        dateCreated: json["date_created"],
      );

  Map<String, dynamic> toJson() => {
        "category_name": categoryName,
        "category_image": categoryImage,
        "date_created": dateCreated,
      };
}

class CategoryModel {
  final int id;
  final String categoryName;
  final String? categoryImageUrl;

  CategoryModel({
    required this.id,
    required this.categoryName,
    this.categoryImageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      categoryName: json['category_name'],
      categoryImageUrl: json['category_image_url'],
    );
  }
}

class ProductModel {
  final int id;
  final String? barcod;
  final String name;
  final String? imageUrl;
  final String? brandName;
  final String? categoryName;
  final int boxQuantity;
  final int itemQuantity;
  final double? boxPrice;
  final double? itemPrice;
  final String? unit;
  final int? pack;

  ProductModel({
    required this.id,
    required this.barcod,
    required this.name,
    required this.imageUrl,
    required this.brandName,
    required this.categoryName,
    required this.boxQuantity,
    required this.itemQuantity,
    required this.boxPrice,
    required this.itemPrice,
    required this.unit,
    required this.pack,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final product = json['Product'] ?? {};
    return ProductModel(
      id: product['id'],
      name: product['name'] ?? '',
      barcod: product['barcod'],
      imageUrl: product['image_url'],
      brandName: product['Brand']?['brand_name'],
      categoryName: product['Category']?['category_name'],
      boxQuantity: json['box_quantity'],
      itemQuantity: json['items_quantity'],
      boxPrice: product['ProductPrice']?['box_price']?.toDouble(),
      itemPrice: product['ProductPrice']?['item_price']?.toDouble(),
      unit: product['unit'],
      pack: product['number_of_items_per_box'],
    );
  }
}

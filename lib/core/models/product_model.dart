class ProductModel {
  final int id;
  final String? barcod;
  final String name;
  final String? imageUrl;
  final String? brandName;
  final String? categoryName;
  final int boxQuantity;
  final int itemQuantity;
  final double? boxPriceA1;
  final double? itemPriceA1;
  final double? boxPriceA2;
  final double? itemPriceA2;
  final double? boxPriceB1;
  final double? itemPriceB1;
  final double? boxPriceB2;
  final double? itemPriceB2;
  final double? boxPriceC1;
  final double? itemPriceC1;
  final double? boxPriceC2;
  final double? itemPriceC2;
  final double? boxPriceD1;
  final double? itemPriceD1;
  final double? boxPriceD2;
  final double? itemPriceD2;
  final String? unit;
  final int? pack;
  final bool? isTaxable;

  ProductModel({
    required this.id,
    required this.barcod,
    required this.name,
    required this.imageUrl,
    required this.brandName,
    required this.categoryName,
    required this.boxQuantity,
    required this.itemQuantity,
    required this.boxPriceA1,
    required this.itemPriceA1,
    required this.boxPriceA2,
    required this.itemPriceA2,
    required this.boxPriceB1,
    required this.itemPriceB1,
    required this.boxPriceB2,
    required this.itemPriceB2,
    required this.boxPriceC1,
    required this.itemPriceC1,
    required this.boxPriceC2,
    required this.itemPriceC2,
    required this.boxPriceD1,
    required this.itemPriceD1,
    required this.boxPriceD2,
    required this.itemPriceD2,
    required this.unit,
    required this.pack,
    required this.isTaxable,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final product = json['Product'] ?? {};
    final productPrice = product['ProductPrice'] ?? {};

    return ProductModel(
      id: product['id'],
      name: product['name'] ?? '',
      barcod: product['barcod'],
      imageUrl: product['image_url'],
      brandName: product['Brand']?['brand_name'],
      categoryName: product['Category']?['category_name'],
      boxQuantity: json['box_quantity'],
      itemQuantity: json['items_quantity'],
      boxPriceA1: productPrice['box_price_a1']?.toDouble(),
      itemPriceA1: productPrice['item_price_a1']?.toDouble(),
      boxPriceA2: productPrice['box_price_a2']?.toDouble(),
      itemPriceA2: productPrice['item_price_a2']?.toDouble(),
      boxPriceB1: productPrice['box_price_b1']?.toDouble(),
      itemPriceB1: productPrice['item_price_b1']?.toDouble(),
      boxPriceB2: productPrice['box_price_b2']?.toDouble(),
      itemPriceB2: productPrice['item_price_b2']?.toDouble(),
      boxPriceC1: productPrice['box_price_c1']?.toDouble(),
      itemPriceC1: productPrice['item_price_c1']?.toDouble(),
      boxPriceC2: productPrice['box_price_c2']?.toDouble(),
      itemPriceC2: productPrice['item_price_c2']?.toDouble(),
      boxPriceD1: productPrice['box_price_d1']?.toDouble(),
      itemPriceD1: productPrice['item_price_d1']?.toDouble(),
      boxPriceD2: productPrice['box_price_d2']?.toDouble(),
      itemPriceD2: productPrice['item_price_d2']?.toDouble(),
      unit: product['unit'],
      pack: product['number_of_items_per_box'],
      isTaxable: product['is_taxable'],
    );
  }
}

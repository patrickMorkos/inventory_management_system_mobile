import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/controllers/product_controller.dart';
import 'package:inventory_management_system_mobile/view/screens/Web/ProductsContent/products_table.dart';

class ProductsContent extends StatelessWidget {
  ProductsContent({super.key});
  final controller = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    controller.fetchProducts();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ProductsTable(),
    );
  }
}

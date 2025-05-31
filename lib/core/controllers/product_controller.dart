import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/data/api_service.dart';
import '../models/product_model.dart';

class ProductController extends GetxController {
  var products = <ProductModel>[].obs;
  var filteredProducts = <ProductModel>[].obs;
  var isLoading = false.obs;
  var currentPage = 1.obs;
  final itemsPerPage = 10;
  final searchController = TextEditingController();

  void fetchProducts() async {
    try {
      isLoading.value = true;
      final response = await getRequest(
        path:
            '/api/main-warehouse-stock/get-all-main-warehouse-stock-products?client_id=4',
        requireToken: true,
      );
      products.value =
          (response as List).map((e) => ProductModel.fromJson(e)).toList();
      filteredProducts.value = products;
    } catch (e) {
      Get.snackbar("Error", "Failed to load products");
    } finally {
      isLoading.value = false;
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      filteredProducts.value = products;
    } else {
      filteredProducts.value = products
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    currentPage.value = 1;
  }
}

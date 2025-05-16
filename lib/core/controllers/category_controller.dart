import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/models/category_model.dart';

import 'package:inventory_management_system_mobile/data/api_service.dart';

class CategoryController extends GetxController {
  RxList<CategoryModel> categories = <CategoryModel>[].obs;
  RxList<CategoryModel> filteredCategories = <CategoryModel>[].obs;
  RxBool isLoading = false.obs;
  RxInt currentPage = 1.obs;

  final int itemsPerPage = 10;

  TextEditingController searchController = TextEditingController();

  Future<void> fetchCategories() async {
    isLoading.value = true;
    final data = await getRequest(
        path: "/api/category/get-all-categories", requireToken: true);
    categories.value =
        (data as List).map((e) => CategoryModel.fromJson(e)).toList();
    filteredCategories.value = categories;
    isLoading.value = false;
  }

  void search(String query) {
    filteredCategories.value = categories.where((cat) {
      return cat.categoryName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<bool> createCategory(String name, dynamic image) async {
    final body = {"category_name": name};
    final files = {"category_image_url": image}; // Still fine

    final res = await postRequestWithFiles(
      path: "/api/category/create-category",
      data: body,
      files: files,
      requireToken: true,
    );

    if (res?['id'] != null) {
      await fetchCategories();
      clearSearch();
      return true;
    } else {
      final error = res?['error'] ?? 'Failed to create category';
      Get.snackbar(
        "Error",
        error,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return false;
  }

  Future<bool> updateCategory(int id, String name, dynamic image) async {
    final body = {"category_name": name};
    final files = {"category_image_url": image};

    final res = await putRequestWithFiles(
      path: "/api/category/update-category/$id",
      data: body,
      files: files,
      requireToken: true,
    );

    if (res?['id'] != null) {
      await fetchCategories();
      clearSearch();
      return true;
    } else {
      final error = res?['error'] ?? 'Failed to create category';
      Get.snackbar(
        "Error",
        error,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return false;
  }

  Future<bool> deleteCategory(int id) async {
    final res = await deleteRequest(
      path: "/api/category/delete-category/$id",
      body: {},
      requireToken: true,
    );

    if (res?["status"] == 200) {
      await fetchCategories();
      clearSearch();
      return true;
    } else {
      final error = res?['error'] ?? 'Failed to delete category';
      Get.snackbar("Error", error, snackPosition: SnackPosition.BOTTOM);
    }
    return false;
  }

  void clearSearch() {
    searchController.clear();
    filteredCategories.value = categories;
  }
}

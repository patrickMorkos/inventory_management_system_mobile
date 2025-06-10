import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/controllers/category_controller.dart';
import 'categories_table.dart';

class CategoriesContent extends StatelessWidget {
  CategoriesContent({super.key});
  final controller = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    controller.fetchCategories();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CategoriesTable(),
      ),
    );
  }
}

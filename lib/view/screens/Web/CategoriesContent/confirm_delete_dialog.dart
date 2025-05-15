import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/controllers/category_controller.dart';

Future<void> showConfirmDeleteDialog(int categoryId) async {
  final controller = Get.find<CategoryController>();

  Get.defaultDialog(
    title: "Delete Category",
    middleText: "Are you sure you want to delete this category?",
    textConfirm: "Delete",
    textCancel: "Cancel",
    confirmTextColor: Colors.white,
    onConfirm: () async {
      await controller.deleteCategory(categoryId);
      Get.back(); // Close the dialog
    },
  );
}

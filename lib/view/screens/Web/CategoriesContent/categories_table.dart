// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/controllers/category_controller.dart';
import 'package:inventory_management_system_mobile/view/screens/web/categoriescontent/categories_form_modal.dart';
import 'confirm_delete_dialog.dart';

class CategoriesTable extends StatelessWidget {
  CategoriesTable({super.key});

  final CategoryController controller =
      Get.put(CategoryController(), permanent: true);
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.filteredCategories;
      final totalItems = items.length;
      final itemsPerPage = controller.itemsPerPage;

      final totalPages = (totalItems / itemsPerPage).ceil();
      final currentPage = controller.currentPage.value > totalPages
          ? totalPages
          : controller.currentPage.value;

      final start = (currentPage - 1) * itemsPerPage;
      final end = (start + itemsPerPage).clamp(0, totalItems);
      final pageItems =
          (start < totalItems && start >= 0) ? items.sublist(start, end) : [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search and Create
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 250,
                child: TextField(
                  controller: controller.searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search Category',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: controller.search,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const CategoryFormModal(isEdit: false),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Create"),
              )
            ],
          ),
          const SizedBox(height: 20),

          // Table
          Expanded(
            child: controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          children: [
                            Table(
                              columnWidths: const {
                                0: FlexColumnWidth(1), // ID (10%)
                                1: FlexColumnWidth(3.5), // Name (35%)
                                2: FlexColumnWidth(2), // Image (20%)
                                3: FlexColumnWidth(3.5), // Actions (35%)
                              },
                              border: TableBorder.all(
                                  color: Colors.grey.shade300, width: 1),
                              children: [
                                // Header
                                TableRow(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade100),
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text("ID",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text("Name",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text("Image",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text("Actions",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),

                                // Rows
                                ...pageItems.map((cat) {
                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(cat.id.toString()),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(cat.categoryName),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: cat.categoryImageUrl != null
                                            ? Image.network(
                                                cat.categoryImageUrl!,
                                                height: 50)
                                            : const Text("No Image"),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) =>
                                                      CategoryFormModal(
                                                    isEdit: true,
                                                    categoryId: cat.id,
                                                    initialName:
                                                        cat.categoryName,
                                                  ),
                                                );
                                              },
                                            ),
                                            // IconButton(
                                            //   icon: const Icon(Icons.delete),
                                            //   onPressed: () =>
                                            //       showConfirmDeleteDialog(
                                            //           cat.id),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
                  ),
          ),

          // Pagination
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: currentPage > 1
                    ? () => controller.currentPage.value--
                    : null,
                icon: const Icon(Icons.arrow_back),
              ),
              Text("Page $currentPage of $totalPages"),
              IconButton(
                onPressed: currentPage < totalPages
                    ? () => controller.currentPage.value++
                    : null,
                icon: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      );
    });
  }
}

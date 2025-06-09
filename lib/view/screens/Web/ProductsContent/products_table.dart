import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/controllers/product_controller.dart';
import 'package:inventory_management_system_mobile/view/screens/web/ProductsContent/prices_popup.dart';
import 'package:inventory_management_system_mobile/view/screens/web/ProductsContent/products_form_modal.dart';

class ProductsTable extends StatelessWidget {
  ProductsTable({super.key});

  final controller = Get.find<ProductController>();

  TableRow buildTableHeader(List<String> headers) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade100),
      children: headers
          .map((header) => Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  header,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ))
          .toList(),
    );
  }

  Widget tableCell(String content) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(content, overflow: TextOverflow.ellipsis),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.filteredProducts;
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
                'All Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 250,
                child: TextField(
                  controller: controller.searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search Products',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: controller.search,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => CreateProductModal(),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Create'),
              )
            ],
          ),
          const SizedBox(height: 20),

          //Table
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
                                0: FlexColumnWidth(1),
                                1: FlexColumnWidth(2),
                                2: FlexColumnWidth(2.5),
                                3: FlexColumnWidth(2),
                                4: FlexColumnWidth(2.5),
                                5: FlexColumnWidth(2.5),
                                6: FlexColumnWidth(1),
                                7: FlexColumnWidth(1),
                                8: FlexColumnWidth(1),
                                9: FlexColumnWidth(1.5),
                                10: FlexColumnWidth(1),
                                11: FlexColumnWidth(2),
                              },
                              border: TableBorder.all(
                                  color: Colors.grey.shade300, width: 1),
                              children: [
                                buildTableHeader([
                                  'ID',
                                  'Barcode',
                                  'Name',
                                  'Image',
                                  'Brand',
                                  'Category',
                                  'Box Qty',
                                  'Item Qty',
                                  'Prices',
                                  'Unit',
                                  'Pack',
                                  'Actions'
                                ]),
                                for (final product in pageItems)
                                  TableRow(
                                    children: [
                                      tableCell(product.id.toString()),
                                      tableCell(product.barcod ?? '-'),
                                      tableCell(product.name),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: product.imageUrl != null
                                            ? Image.network(
                                                product.imageUrl!,
                                                height: 50,
                                              )
                                            : const Icon(
                                                Icons.image_not_supported),
                                      ),
                                      tableCell(product.brandName ?? '-'),
                                      tableCell(product.categoryName ?? '-'),
                                      tableCell(product.boxQuantity.toString()),
                                      tableCell(
                                          product.itemQuantity.toString()),
                                      Center(
                                        child: IconButton(
                                          icon: const Icon(Icons.price_change),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) =>
                                                  PricesPopup(product: product),
                                            );
                                          },
                                        ),
                                      ),
                                      tableCell(product.unit ?? '-'),
                                      tableCell(
                                          product.pack?.toString() ?? '-'),
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
                                                      CreateProductModal(
                                                          product: product),
                                                );
                                              },
                                            ),
                                            // IconButton(
                                            //   icon: const Icon(Icons.delete),
                                            //   onPressed: () {},
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 16),

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
        ],
      );
    });
  }
}

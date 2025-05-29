import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/controllers/web_order_controller.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';

class OrdersTable extends StatelessWidget {
  OrdersTable({super.key});

  final controller = Get.find<WebOrderController>();

  TableRow buildTableHeader(List<String> headers) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade100),
      children: headers
          .map((header) => Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  header,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ))
          .toList(),
    );
  }

  Widget tableCell(String content) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(content),
    );
  }

  Widget buildPaginationControls({
    required int currentPage,
    required int totalPages,
    required VoidCallback onPrevious,
    required VoidCallback onNext,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: currentPage > 1 ? onPrevious : null,
        ),
        Text('Page $currentPage of $totalPages'),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: currentPage < totalPages ? onNext : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<WebOrderController>();
      final items = controller.filteredOrders;
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
          // Search
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Orders',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 250,
                child: TextField(
                  controller: controller.searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search Orders',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: controller.search,
                ),
              ),
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
                                0: FlexColumnWidth(0.8), // ID
                                1: FlexColumnWidth(1.5), // Client
                                2: FlexColumnWidth(1.5), // Salesman
                                3: FlexColumnWidth(1), // Sale Type
                                4: FlexColumnWidth(1), // USD
                                5: FlexColumnWidth(1), // LBP
                                6: FlexColumnWidth(1.5), // Issue Date
                                7: FlexColumnWidth(1.5), // Due Date
                                8: FlexColumnWidth(1), // Paid
                                9: FlexColumnWidth(1), // Actions
                              },
                              border:
                                  TableBorder.all(color: Colors.grey.shade300),
                              children: [
                                buildTableHeader([
                                  'ID',
                                  'Client',
                                  'Salesman',
                                  'Sale Type',
                                  'USD',
                                  'LBP',
                                  'Issue Date',
                                  'Due Date',
                                  'Paid',
                                  'Actions'
                                ]),
                                for (final order in pageItems)
                                  TableRow(
                                    children: [
                                      tableCell(order.id.toString()),
                                      tableCell(
                                          '${order.client ?? ''} ${order.client ?? ''}'),
                                      tableCell(
                                          '${order.salesman ?? ''} ${order.salesman ?? ''}'),
                                      tableCell(order.saleType ?? '-'),
                                      tableCell(order.totalUsd.toString()),
                                      tableCell(order.totalLbp.toString()),
                                      tableCell(formatDate(
                                          order.issueDate.toString())),
                                      tableCell(
                                          formatDate(order.dueDate.toString())),
                                      tableCell(order.isPaid ? 'No' : 'Yes'),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Tooltip(
                                              message: 'Export order to Excel',
                                              child: IconButton(
                                                icon:
                                                    const Icon(Icons.download),
                                                onPressed: () {
                                                  final saleId = order
                                                      .id; // ensure `order` is accessible here
                                                  controller.exportSaleProducts(
                                                      saleId);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
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

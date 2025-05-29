import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/controllers/logged_in_user_controller.dart';
import 'package:inventory_management_system_mobile/core/models/order_model.dart';
import 'package:inventory_management_system_mobile/data/api_service.dart';
import 'dart:html' as html; // For web download

class WebOrderController extends GetxController {
  var isLoading = false.obs;
  var orders = <OrderModel>[].obs;
  var filteredOrders = <OrderModel>[].obs;
  var currentPage = 1.obs;
  int itemsPerPage = 10;

  final searchController = TextEditingController();

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      final userId = Get.find<LoggedInUserController>().loggedInUser.value.id;
      final data = await getRequest(
        path: "/api/sale/get-all-client-sales/$userId?client_id=-1",
        requireToken: true,
      );
      orders.value = (data as List).map((e) => OrderModel.fromJson(e)).toList();
      filteredOrders.value = orders;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportSaleProducts(int saleId) async {
    try {
      final response = await getRequest(
        path: "/api/sale/export-sale-products/$saleId",
        requireToken: true,
        isBytesResponse: true,
      );

      // Create a Blob and anchor tag to download file
      final blob = html.Blob([response],
          'text/csv'); // or response.bodyBytes if using http.get directly
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", "sale_products_$saleId.csv") // use .csv
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      Get.snackbar("Error", "Failed to export sale products: $e");
    }
  }

  void search(String query) {
    filteredOrders.value = orders.where((o) {
      return o.client.toLowerCase().contains(query.toLowerCase()) ||
          o.salesman.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void clearSearch() {
    searchController.clear();
    filteredOrders.value = orders;
  }
}

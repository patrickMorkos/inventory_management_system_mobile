//! This is the client stock controller to globally save the client stock products info
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/data/api_service.dart';

class ClientStockController extends GetxController {
  RxList<dynamic> clientStockProducts = RxList<dynamic>([]);

  // Fetch all client stock products from the server
  Future<void> fetchClientStockProducts(int clientId) async {
    try {
      final response = await getRequest(
        path: "/api/client-stock/get-all-client-stock-products/$clientId",
        requireToken: true,
      );
      clientStockProducts.value = response;
    } catch (e) {
      debugPrint("Error fetching client stock products: $e");
    }
  }

  // Update product quantity
  Future<void> updateProductQuantity(
      int clientId, int productId, int quantity) async {
    try {
      await putRequest(
        path: "/api/client-stock/update-products-quantities/$clientId",
        body: {
          "product_id": productId,
          "quantity": quantity,
        },
        requireToken: true,
      );

      for (int i = 0; i < clientStockProducts.length; i++) {
        if (clientStockProducts[i]["Product"]["id"] == productId) {
          clientStockProducts[i]["quantity"] = quantity;
        }
      }
    } catch (e) {
      debugPrint("Error updating product quantity: $e");
    }
  }

  // Remove a product from the client stock
  Future<void> deleteProduct(int clientId, int productId) async {
    try {
      await deleteRequest(
        path: "/api/client-stock/remove-product-from-client-stock/$clientId",
        body: {
          "product_id": productId,
        },
        requireToken: true,
      );

      clientStockProducts.removeWhere(
        (product) => product["Product"]["id"] == productId,
      );
    } catch (e) {
      debugPrint("Error deleting product: $e");
    }
  }

  // Set the client stock products info
  void setClientStockProducts(List<dynamic> clientStockProductsList) {
    clientStockProducts.value = clientStockProductsList;
  }

  Future<void> addProductToClientStock(
      int clientId, int productId, int quantity) async {
    try {
      await postRequest(
        path: "/api/client-stock/add-products/$clientId",
        body: {
          "product_id": productId,
          "quantity": quantity,
        },
        requireToken: true,
      ).then((value) => {
            if (value["error"] != null)
              {
                Get.snackbar(
                  duration: Duration(seconds: 6),
                  "Error",
                  "${value["error"]}",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                ),
                throw Exception(
                    "Failed to add product to client stock ${value["error"]}"),
              }
          });
      await fetchClientStockProducts(clientId); // Refresh the client stock
    } catch (e) {
      throw Exception("Failed to add product to client stock");
    }
  }
}

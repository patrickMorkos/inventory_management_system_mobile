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

  Future<void> updateProductQuantities(
      int clientId, int productId, int boxQuantity, int itemQuantity) async {
    print("Sending boxQuantity: $boxQuantity, itemQuantity: $itemQuantity");
    try {
      await putRequest(
        path: "/api/client-stock/update-products-quantities/$clientId",
        body: {
          "product_id": productId,
          "box_quantity": boxQuantity,
          "items_quantity": itemQuantity,
        },
        requireToken: true,
      );

      // Update only the affected product in the list
      final productIndex = clientStockProducts
          .indexWhere((product) => product["Product"]["id"] == productId);
      if (productIndex != -1) {
        clientStockProducts[productIndex]["box_quantity"] = boxQuantity;
        clientStockProducts[productIndex]["items_quantity"] = itemQuantity;
      }

      update(); // Notify UI of changes
    } catch (e) {
      debugPrint("Error updating product quantities: $e");
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
      int clientId, int productId, int boxQuantity, int itemQuantity) async {
    try {
      await postRequest(
        path: "/api/client-stock/add-products/$clientId",
        body: {
          "product_id": productId,
          "box_quantity": boxQuantity,
          "items_quantity": itemQuantity, // Added item quantity field
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
      await fetchClientStockProducts(clientId); // Refresh the client stock list
    } catch (e) {
      throw Exception("Failed to add product to client stock: $e");
    }
  }
}

//! This is the client stock controller to globally save the client stock products info
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
      print("Error fetching client stock products: $e");
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
      print("Error updating product quantity: $e");
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
      print("Error deleting product: $e");
    }
  }

  // Set the client stock products info
  void setClientStockProducts(List<dynamic> clientStockProductsList) {
    clientStockProducts.value = clientStockProductsList;
  }
}

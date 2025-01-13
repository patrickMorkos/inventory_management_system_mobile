//! This is the order controller to globally save the order info
import 'dart:convert';

import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/data/api_service.dart';

class OrderController extends GetxController {
  RxMap<String, dynamic> orderInfo = RxMap<String, dynamic>(
    {
      "products": [],
    },
  );

  void addProductToOrder(Map<dynamic, dynamic> productObj, int quantity) {
    var existingProduct = orderInfo["products"].firstWhere(
      (product) => product["product"] == productObj,
      orElse: () => null,
    );

    if (existingProduct != null) {
      existingProduct["quantity"] += quantity;
    } else {
      Map<String, dynamic> product = {
        "product": productObj,
        "quantity": quantity,
      };
      orderInfo["products"].add(product);
    }
  }

  void removeProductFromOrder(Map<dynamic, dynamic> productObj) {
    orderInfo["products"]
        .removeWhere((product) => product["product"] == productObj);
  }

  void increaseProductQuantity(Map<dynamic, dynamic> productObj) {
    orderInfo["products"].firstWhere(
        (product) => product["product"] == productObj)["quantity"] += 1;
  }

  void decreaseProductQuantity(Map<dynamic, dynamic> productObj) {
    orderInfo["products"].firstWhere(
        (product) => product["product"] == productObj)["quantity"] -= 1;
  }

  void createOrder(
      totalPriceUsd, isPendingPayment, saleType, clientId, salesmanId) async {
    List<Map<String, dynamic>> orderProducts = [];
    for (var element in orderInfo["products"]) {
      orderProducts.add({
        "product_id": element["product"]["id"],
        "quantity": element["quantity"],
      });
    }

    int sale_type_id = 0;
    if (saleType == "Cash Van") {
      sale_type_id = 1;
    } else if (saleType == "Presale") {
      sale_type_id = 2;
    }

    Map<String, dynamic> orderData = {
      "total_price_usd": totalPriceUsd,
      "total_price_lbp": totalPriceUsd * 89500,
      "vat_value": 11,
      "is_pending_payment": isPendingPayment,
      "sale_type_id": sale_type_id,
      "client_id": clientId,
      "products": orderProducts,
    };
    // dynamic body = jsonEncode(orderData);
    await postRequest(
      path: "/api/sale/create-sale/$salesmanId",
      body: orderData,
      requireToken: true,
    );
  }
}

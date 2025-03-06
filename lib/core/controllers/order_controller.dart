//! This is the order controller to globally save the order info

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/controllers/van_products_controller.dart';
import 'package:inventory_management_system_mobile/data/api_service.dart';
import 'package:nb_utils/nb_utils.dart';

class OrderController extends GetxController {
  RxMap<String, dynamic> orderInfo = RxMap<String, dynamic>(
    {
      "products": [],
      "saleProducts": [],
      "saleType": "Cash Van",
    },
  );

  void clearOrderController() {
    orderInfo.clear();
    orderInfo.addAll({
      "products": [],
      "saleProducts": [],
      "saleType": "Cash Van",
    });
    update();
  }

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

  void addSaleProductsToOrder(
      List<dynamic> saleProductsList, String priceSelection) {
    // This variable is the vanProductsController
    final VanProductsController vanProductsController =
        Get.put(VanProductsController());
    if (!orderInfo.containsKey("saleProducts")) {
      orderInfo["saleProducts"] = [];
    }

    for (var saleProduct in saleProductsList) {
      if (priceSelection == "New Prices") {
        // Retrieve the corresponding product from vanProductsController
        var vanProduct = vanProductsController.vanProductsList.firstWhere(
          (vp) => vp["Product"]["id"] == saleProduct["Product"]["id"],
          orElse: () => null,
        );

        // Update product_price with the new price if vanProduct exists
        if (vanProduct != null) {
          saleProduct["product_price"] =
              vanProduct["Product"]["ProductPrice"]["price"];
        }
      }

      // Check if the product already exists in orderInfo["saleProducts"]
      var existingProduct = orderInfo["saleProducts"].firstWhere(
        (product) => product["product"] == saleProduct["Product"],
        orElse: () => null,
      );

      if (existingProduct != null) {
        existingProduct["quantity"] += saleProduct["quantity"];
      } else {
        Map<String, dynamic> newProduct = {
          "product": saleProduct["Product"],
          "quantity": saleProduct["quantity"],
          "product_price": saleProduct["product_price"],
        };
        orderInfo["saleProducts"].add(newProduct);
      }
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

  void resetOrder() {
    orderInfo["products"] = [];
  }

  void createOrder(
      totalPriceUsd, isPendingPayment, saleType, clientId, salesmanId) async {
    List<Map<String, dynamic>> orderProducts = [];

    // Check if orderInfo exists and contains products
    if (orderInfo["products"] != null && orderInfo["products"].isNotEmpty) {
      for (var element in orderInfo["products"]) {
        orderProducts.add({
          "product_id": element["product"]["id"],
          "quantity": element["quantity"],
          "product_price": double.parse(
            (element["product"]["ProductPrice"]["price"]).toString(),
          ),
        });
      }
    }

    // Check if orderInfo exists and contains saleProducts
    if (orderInfo["saleProducts"] != null &&
        orderInfo["saleProducts"].isNotEmpty) {
      for (var element in orderInfo["saleProducts"]) {
        orderProducts.add({
          "product_id": element["product"]["id"],
          "quantity": element["quantity"],
          "product_price":
              element["product_price"], // Assuming it's already a number
        });
      }
    }

    int saleTypeId = 0;
    if (saleType == "Cash Van") {
      saleTypeId = 1;
    } else if (saleType == "Presale") {
      saleTypeId = 2;
    }

    Map<String, dynamic> orderData = {
      "total_price_usd": totalPriceUsd,
      "total_price_lbp": totalPriceUsd * 89500,
      "vat_value": 11,
      "is_pending_payment": isPendingPayment,
      "sale_type_id": saleTypeId,
      "client_id": clientId,
      "products": orderProducts,
    };

    await postRequest(
      path: "/api/sale/create-sale/$salesmanId",
      body: orderData,
      requireToken: true,
    ).then((response) {
      if (response['id'] != null) {
        Fluttertoast.showToast(
          msg: "Order created successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Get.toNamed("/dashboard");
        resetOrder();
      } else {
        Fluttertoast.showToast(
          msg: "Error: ${response['error']}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    });
    // Reset the orderInfo after creating the order
    clearOrderController();
  }
}

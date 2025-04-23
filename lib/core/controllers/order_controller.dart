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

  void addProductToOrder(Map<dynamic, dynamic> productObj, int boxQuantity) {
    var existingProduct = orderInfo["products"].firstWhere(
      (product) => product["product"] == productObj,
      orElse: () => null,
    );

    if (existingProduct != null) {
      existingProduct["box_quantity"] += boxQuantity;
    } else {
      Map<String, dynamic> product = {
        "product": productObj,
        "box_quantity": boxQuantity,
      };
      orderInfo["products"].add(product);
    }
  }

  void addProductToOrderWithItems(
      Map<dynamic, dynamic> productObj, int boxQuantity, int itemQuantity) {
    if (itemQuantity <= 0) {
      return;
    }

    var existingProduct = orderInfo["products"].firstWhere(
      (product) => product["product"] == productObj,
      orElse: () => null,
    );

    if (existingProduct != null) {
      existingProduct["items_quantity"] =
          (existingProduct["items_quantity"] ?? 0) + itemQuantity;
    } else {
      Map<String, dynamic> product = {
        "product": productObj,
        "items_quantity": itemQuantity,
      };
      orderInfo["products"].add(product);
    }

    // print("Product Added: ${productObj["id"]}, Item Quantity: ${itemQuantity}");
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

        // Update product box price with the new box price if vanProduct exists
        if (vanProduct != null) {
          saleProduct["box_price"] = vanProduct["Product"]["ProductPrice"]
                  ["box_price"] ??
              saleProduct["box_price"];
          saleProduct["item_price"] = vanProduct["Product"]["ProductPrice"]
                  ["item_price"] ??
              saleProduct["item_price"];
        }
      }

      // Check if the product already exists in orderInfo["saleProducts"]
      var existingProduct = orderInfo["saleProducts"].firstWhere(
        (product) => product["product"]["id"] == saleProduct["Product"]["id"],
        orElse: () => null,
      );

      if (existingProduct != null) {
        existingProduct["box_quantity"] += saleProduct["box_quantity"] ?? 0;
        existingProduct["items_quantity"] += saleProduct["items_quantity"] ?? 0;
      } else {
        Map<String, dynamic> newProduct = {
          "product": saleProduct["Product"],
          "box_quantity": saleProduct["box_quantity"] ?? 0,
          "box_price": saleProduct["box_price"] ?? 0.0,
          "items_quantity": saleProduct["items_quantity"] ?? 0,
          "item_price": saleProduct["item_price"] ?? 0.0,
        };
        orderInfo["saleProducts"].add(newProduct);
      }
    }
  }

  void removeProductFromOrder(Map<dynamic, dynamic> productObj) {
    orderInfo["products"]?.removeWhere(
        (product) => product["product"]["id"] == productObj["id"]);
  }

  void increaseProductItemQuantity(Map<dynamic, dynamic> productObj) {
    var product = orderInfo["products"].firstWhere(
      (product) => product["product"]["id"] == productObj["id"],
      orElse: () => null,
    );

    if (product != null) {
      product["items_quantity"] = (product["items_quantity"] ?? 0) + 1;
    }
  }

  void decreaseProductItemQuantity(Map<dynamic, dynamic> productObj) {
    var product = orderInfo["products"].firstWhere(
      (product) => product["product"]["id"] == productObj["id"],
      orElse: () => null,
    );

    if (product != null && (product["items_quantity"] ?? 0) > 0) {
      product["items_quantity"] -= 1;
    }
  }

  void increaseProductBoxQuantity(Map<dynamic, dynamic> productObj) {
    orderInfo["products"].firstWhere(
        (product) => product["product"] == productObj)["box_quantity"] += 1;
  }

  void decreaseProductBoxQuantity(Map<dynamic, dynamic> productObj) {
    orderInfo["products"].firstWhere(
        (product) => product["product"] == productObj)["box_quantity"] -= 1;
  }

  void resetOrder() {
    orderInfo["products"] = [];
  }

Future<Map<String, dynamic>?> createOrder(
      totalPriceUsd, isPendingPayment, saleType, clientId, salesmanId) async {
    List<Map<String, dynamic>> orderProducts = [];

    // Check if orderInfo exists and contains products
    if (orderInfo["products"] != null && orderInfo["products"].isNotEmpty) {
      for (var element in orderInfo["products"]) {
        Map<String, dynamic> productData = {
          "product_id": element["product"]["id"],
          "box_quantity": element["box_quantity"] ?? 0,
          "box_price": double.parse(
            ((element["product"]["ProductPrice"]["box_price"]) *
                    (element["product"]["is_taxable"] == true ? 1.11 : 1.0))
                .toStringAsFixed(2),
          ),
          "items_quantity": element["items_quantity"] ?? 0,
          "item_price": double.parse(
            ((element["product"]["ProductPrice"]["item_price"]) *
                    (element["product"]["is_taxable"] == true ? 1.11 : 1.0))
                .toStringAsFixed(2),
          ),
        };

        orderProducts.add(productData);
      }
    }

    // Check if orderInfo exists and contains saleProducts
    if (orderInfo["saleProducts"] != null &&
        orderInfo["saleProducts"].isNotEmpty) {
      for (var element in orderInfo["saleProducts"]) {
        Map<String, dynamic> saleProductData = {
          "product_id": element["product"]["id"],
          "box_quantity": element["box_quantity"] ?? 0,
          "box_price": double.parse(
            ((element["box_price"] ?? 0) *
                    (element["product"]["is_taxable"] == true ? 1.11 : 1.0))
                .toStringAsFixed(2),
          ),
          "items_quantity": element["items_quantity"] ?? 0,
          "item_price": double.parse(
            ((element["item_price"] ?? 0) *
                    (element["product"]["is_taxable"] == true ? 1.11 : 1.0))
                .toStringAsFixed(2),
          ),
        };

        orderProducts.add(saleProductData);
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

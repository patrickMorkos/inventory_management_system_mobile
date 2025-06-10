//! This is the van products controller to globally save the van products info
import 'package:get/get.dart';

class VanProductsController extends GetxController {
  RxList<dynamic> vanProductsList = RxList<dynamic>([]);

  void setVanProductsInfo(List<dynamic> vanProductsList) {
    this.vanProductsList.value = vanProductsList;
  }

  void deductBoxQuantity(int productId, int boxQuantity) {
    for (int i = 0; i < vanProductsList.length; i++) {
      if (vanProductsList[i]["Product"]["id"] == productId) {
        vanProductsList[i]["box_quantity"] =
            vanProductsList[i]["box_quantity"] - boxQuantity;
      }
    }
  }

  void deductItemQuantity(int productId, int itemQuantity) {
    for (int i = 0; i < vanProductsList.length; i++) {
      if (vanProductsList[i]["Product"]["id"] == productId) {
        vanProductsList[i]["items_quantity"] =
            vanProductsList[i]["items_quantity"] - itemQuantity;
      }
    }
  }

  void addItemQuantity(int productId, int itemQuantity) {
    var vanProduct = vanProductsList.firstWhere(
      (vp) => vp["Product"]["id"] == productId,
      orElse: () => null,
    );

    if (vanProduct != null) {
      vanProduct["items_quantity"] =
          (vanProduct["items_quantity"] ?? 0) + itemQuantity;
    }
  }

  void addBoxQuantity(int productId, int boxQuantity) {
    for (int i = 0; i < vanProductsList.length; i++) {
      if (vanProductsList[i]["Product"]["id"] == productId) {
        vanProductsList[i]["box_quantity"] =
            vanProductsList[i]["box_quantity"] + boxQuantity;
      }
    }
  }
}

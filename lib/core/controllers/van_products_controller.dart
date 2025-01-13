//! This is the van products controller to globally save the van products info
import 'package:get/get.dart';

class VanProductsController extends GetxController {
  RxList<dynamic> vanProductsList = RxList<dynamic>([]);

  void setVanProductsInfo(List<dynamic> vanProductsList) {
    this.vanProductsList.value = vanProductsList;
  }

  void deductQuantity(int productId, int quantity) {
    for (int i = 0; i < vanProductsList.length; i++) {
      if (vanProductsList[i]["Product"]["id"] == productId) {
        vanProductsList[i]["quantity"] =
            vanProductsList[i]["quantity"] - quantity;
      }
    }
  }

  void addQuantity(int productId, int quantity) {
    for (int i = 0; i < vanProductsList.length; i++) {
      if (vanProductsList[i]["Product"]["id"] == productId) {
        vanProductsList[i]["quantity"] =
            vanProductsList[i]["quantity"] + quantity;
      }
    }
  }
}

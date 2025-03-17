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

  void addBoxQuantity(int productId, int boxQuantity) {
    for (int i = 0; i < vanProductsList.length; i++) {
      if (vanProductsList[i]["Product"]["id"] == productId) {
        vanProductsList[i]["box_quantity"] =
            vanProductsList[i]["box_quantity"] + boxQuantity;
      }
    }
  }
}

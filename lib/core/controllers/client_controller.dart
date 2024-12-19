//! This is the client controller to globaly save the client info
import 'package:get/get.dart';

class ClientController extends GetxController {
  RxMap<String, dynamic> clientInfo = RxMap<String, dynamic>(
    {
      "id": -1,
      "first_name": "N/A",
      "last_name": "N/A",
    },
  );

  void setClientInfo(Map<String, dynamic> newClient) {
    clientInfo.value = newClient;
  }
}

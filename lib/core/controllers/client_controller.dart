import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ClientController extends GetxController {
  final box = GetStorage();

  RxMap<String, dynamic> clientInfo = RxMap<String, dynamic>(
    {
      "id": -1,
    },
  );

  @override
  void onInit() {
    super.onInit();
    _loadClientCheckIn();
  }

  void setClientInfo(Map<String, dynamic> newClient) {
    clientInfo.value = newClient;
    if (newClient["id"] != -1) {
      box.write("client_check_in", newClient);
    } else {
      box.remove("client_check_in");
    }
  }

  void _loadClientCheckIn() {
    Map<String, dynamic>? storedClient = box.read("client_check_in");
    if (storedClient != null) {
      clientInfo.value = storedClient;
    }
  }
}

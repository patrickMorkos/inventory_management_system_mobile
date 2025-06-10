import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inventory_management_system_mobile/core/models/user_model.dart';
import 'package:nb_utils/nb_utils.dart';

class LoggedInUserController extends GetxController {
  Rx<UserModel> loggedInUser = UserModel(
    id: -1,
    firstName: "",
    lastName: "",
    phoneNumber: "",
    email: "",
    password: "",
    dateOfBirth: "",
    dateOfJoin: "",
    bloodType: "",
    userTypeId: 0,
    usdLbpRate: 0,
  ).obs;

  RxString accessToken = "".obs;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void setUserInfo(UserModel user, String token) {
    loggedInUser.value = user;
    accessToken.value = token;

    box.write("user", user.toJson());
    box.write("token", token);
  }

  void _loadUserData() {
    String? userData = box.read("user");
    String? token = box.read("token");

    if (userData != null && token != null) {
      // ✅ Check if the token is expired before setting it
      if (JwtDecoder.isExpired(token)) {
        logout();
        return;
      }
      loggedInUser.value = UserModel.fromJson(userData);
      accessToken.value = token;
    }
  }

  void logout() {
    box.remove("user");
    box.remove("token");
    box.remove("client_check_in");

    loggedInUser.value = UserModel(
      id: -1,
      firstName: "",
      lastName: "",
      phoneNumber: "",
      email: "",
      password: "",
      dateOfBirth: "",
      dateOfJoin: "",
      bloodType: "",
      userTypeId: 0,
      usdLbpRate: 0,
    );

    accessToken.value = "";

    loggedInUser.refresh();
    accessToken.refresh();
  }
}

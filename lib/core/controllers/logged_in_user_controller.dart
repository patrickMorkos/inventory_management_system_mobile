import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inventory_management_system_mobile/core/models/user_model.dart';

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
      loggedInUser.value = UserModel.fromJson(userData);
      accessToken.value = token;
    }
  }

  void logout() {
    box.erase();
    loggedInUser.value = UserModel(
      id: 0,
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
  }
}

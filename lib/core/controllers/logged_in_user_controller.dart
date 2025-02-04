//! This is the login controller to globaly save the logged in user info
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/models/user_model.dart';

class LoggedInUserController extends GetxController {
  Rx<UserModel> loggedInUser = UserModel(
    id: -1,
    firstName: "N/A",
    lastName: "N/A",
    phoneNumber: "N/A",
    email: "N/A",
    password: "N/A",
    dateOfBirth: "N/A",
    dateOfJoin: "N/A",
    bloodType: "N/A",
    userTypeId: -1,
    usdLbpRate: 0,
  ).obs;

  RxString accessToken = "".obs;

  void setUserInfo(UserModel user, token) {
    loggedInUser.value = user;
    accessToken.value = token;
  }
}

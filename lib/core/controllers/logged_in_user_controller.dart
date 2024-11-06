//! This is the login controller to globaly save the logged in user info
import 'package:get/get.dart';
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
  ).obs;

  RxString accessToken = "".obs;

  void setUserInfo(UserModel user, token) {
    loggedInUser.value = user;
    accessToken.value = token;
  }
}

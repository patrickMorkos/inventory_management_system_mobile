//! This is the api service where post/put/get/delete function are created
import 'dart:convert';

import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/controllers/logged_in_user_controller.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final LoggedInUserController loggedInUserController =
    Get.put(LoggedInUserController());

//Post request API call
Future<dynamic> postRequest({
  required String path,
  required dynamic body,
  bool requireToken = false,
}) async {
  final String url = host + path;
  try {
    final http.Response response = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: <String, String>{
        'Content-Type': 'application/json',
        if (requireToken)
          "Authorization": loggedInUserController.accessToken.value,
      },
    );
    return jsonDecode(response.body);
  } catch (e) {
    Get.snackbar("Error", e.toString());
    debugPrint("------------- ERROR IN postRequest url: $url -------------");
  }
}

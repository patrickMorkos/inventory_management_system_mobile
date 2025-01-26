//! This is the api service where post/put/get/delete function are created
import 'dart:convert';
import 'dart:io';

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
    debugPrint("error in post request: $e");
  }
}

//Get request API call
Future<dynamic> getRequest({
  required String path,
  bool requireToken = false,
}) async {
  final String url = host + path;
  try {
    final http.Response response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        if (requireToken)
          "Authorization": loggedInUserController.accessToken.value,
      },
    );
    return jsonDecode(response.body);
  } catch (e) {
    Get.snackbar("Error", e.toString());
    debugPrint("------------- ERROR IN getRequest url: $url -------------");
    debugPrint("error in get request: $e");
  }
}

//Put request API call
Future<dynamic> putRequest({
  required String path,
  required dynamic body,
  bool requireToken = false,
}) async {
  final String url = host + path;
  try {
    final http.Response response = await http.put(
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
    debugPrint("------------- ERROR IN putRequest url: $url -------------");
    debugPrint("error in put request: $e");
  }
}

//Delete request API call
Future<dynamic> deleteRequest({
  required String path,
  required dynamic body,
  bool requireToken = false,
}) async {
  final String url = host + path;
  try {
    final http.Response response = await http.delete(
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
    debugPrint("------------- ERROR IN deleteRequest url: $url -------------");
    debugPrint("error in delete request: $e");
  }
}

Future<dynamic> postRequestWithFiles({
  required String path,
  required Map<String, dynamic> data,
  required Map<String, File?> files,
  bool requireToken = false,
}) async {
  final String url = host + path;
  final request = http.MultipartRequest('POST', Uri.parse(url));

  try {
    // Add data fields
    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add file fields
    files.forEach((key, file) {
      if (file != null) {
        request.files.add(http.MultipartFile(
          key,
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: file.path.split('/').last,
        ));
      }
    });

    // Add headers
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      if (requireToken)
        "Authorization": loggedInUserController.accessToken.value,
    });

    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    // Parse and return the response
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to upload files. Status code: ${response.statusCode}. Response: ${response.body}',
      );
    }
  } catch (e) {
    Get.snackbar("Error", e.toString());
    debugPrint(
        "------------- ERROR IN postRequestWithFiles url: $url -------------");
    debugPrint("error in post request with files: $e");
  }
}

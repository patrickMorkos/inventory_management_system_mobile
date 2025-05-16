//! This is the api service where post/put/get/delete function are created
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/controllers/logged_in_user_controller.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
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
    // Get.snackbar("Error", e.toString());
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
    // Get.snackbar("Error", e.toString());
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
    // Get.snackbar("Error", e.toString());
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
    // Get.snackbar("Error", e.toString());
    debugPrint("------------- ERROR IN deleteRequest url: $url -------------");
    debugPrint("error in delete request: $e");
  }
}

Future<dynamic> postRequestWithFiles({
  required String path,
  required Map<String, dynamic> data,
  required Map<String, dynamic> files,
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
    for (final entry in files.entries) {
      final key = entry.key;
      final file = entry.value;

      if (file == null) continue;

      if (kIsWeb && file is Uint8List) {
        request.files.add(http.MultipartFile.fromBytes(
          key,
          file,
          filename: "web_image.png", // you can use another name if needed
        ));
      } else if (file is File) {
        request.files.add(await http.MultipartFile.fromPath(
          key,
          file.path,
        ));
      } else {
        throw Exception(
            "Unsupported file type for key '$key': ${file.runtimeType}");
      }
    }

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
      return {
        'error': jsonDecode(response.body)['error'] ??
            'Upload failed with status ${response.statusCode}',
      };
    }
  } catch (e) {
    // Get.snackbar("Error", e.toString());
    debugPrint(
        "------------- ERROR IN postRequestWithFiles url: $url -------------");
    debugPrint("error in post request with files: $e");
  }
}

Future<dynamic> putRequestWithFiles({
  required String path,
  required Map<String, dynamic> data,
  required Map<String, dynamic> files,
  bool requireToken = false,
}) async {
  final String url = host + path;
  final request = http.MultipartRequest('PUT', Uri.parse(url));

  try {
    // Add data fields
    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add file fields
    for (final entry in files.entries) {
      final key = entry.key;
      final file = entry.value;

      if (file == null) continue;

      if (kIsWeb && file is Uint8List) {
        request.files.add(http.MultipartFile.fromBytes(
          key,
          file,
          filename: "web_image.png",
        ));
      } else if (file is File) {
        request.files.add(await http.MultipartFile.fromPath(
          key,
          file.path,
        ));
      } else {
        throw Exception(
            "Unsupported file type for key '$key': ${file.runtimeType}");
      }
    }

    // Add headers
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      if (requireToken)
        "Authorization": loggedInUserController.accessToken.value,
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {
        'error': jsonDecode(response.body)['error'] ??
            'Upload failed with status ${response.statusCode}',
      };
    }
  } catch (e) {
    // Get.snackbar("Error", e.toString());
    debugPrint(
        "------------- ERROR IN putRequestWithFiles url: $url -------------");
    debugPrint("error: $e");
  }
}

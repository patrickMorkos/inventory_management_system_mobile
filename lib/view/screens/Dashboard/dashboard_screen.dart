import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/controllers/logged_in_user_controller.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final LoggedInUserController loggedInUserController =
      Get.put(LoggedInUserController());

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
      ),
    );
  }
}

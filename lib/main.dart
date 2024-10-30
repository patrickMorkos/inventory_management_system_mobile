import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/Navigation/navigation.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:inventory_management_system_mobile/view/screens/SplashScreen/splash_screen.dart';

void main() {
  runApp(const MainApp());
}

// This is the main widget of the app
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeData(
        primaryColor: kMainColor,
      ),
      home: const SafeArea(
        child: SplashScreen(),
      ),
      getPages: Navigation().getNavigationList(),
    );
  }
}

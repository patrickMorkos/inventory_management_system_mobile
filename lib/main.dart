import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inventory_management_system_mobile/core/Navigation/navigation.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:inventory_management_system_mobile/core/controllers/logged_in_user_controller.dart';
import 'package:inventory_management_system_mobile/view/screens/Splash/splash_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize Controllers
  final LoggedInUserController loggedInUserController =
      Get.put(LoggedInUserController());

  runApp(MainApp(loggedInUserController: loggedInUserController));
}

class MainApp extends StatelessWidget {
  final LoggedInUserController loggedInUserController;

  const MainApp({super.key, required this.loggedInUserController});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeData(
        primaryColor: kMainColor,
      ),
      home: SafeArea(
        child: _getInitialScreen(),
      ),
      getPages: Navigation().getNavigationList(),
    );
  }

  /// Decides the initial screen based on authentication status
  Widget _getInitialScreen() {
    return loggedInUserController.accessToken.value.isNotEmpty
        ? DashboardScreen()
        : SplashScreen();
  }
}

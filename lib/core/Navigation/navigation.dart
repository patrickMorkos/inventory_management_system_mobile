//! This is a navigator where routes for each screen are set
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/view/screens/Dashboard/dashboard_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/auth/LoginScreen/login_screen.dart';

class Navigation {
  List<GetPage<dynamic>> routes = [
    GetPage(name: "/login", page: () => const LoginScreen()),
    GetPage(name: "/dashboard", page: () => DashboardScreen())
  ];
  List<GetPage<dynamic>> getNavigationList() {
    return routes;
  }
}

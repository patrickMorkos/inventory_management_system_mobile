//! This is a navigator where routes for each screen are set
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/view/screens/AllCategories/all_categories_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/AllProducts/all_products_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/ClientQrCodeScan/client_qr_code_scan_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/ClientStock/client_stock_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/Clients/clients_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/CreateNewClient/create_new_client_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/CreateNewOrder/create_new_order_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/Dashboard/dashboard_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/Login/login_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/ReturnProduct/return_product_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/VanCategories/van_categories_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/VanProducts/van_products_screen.dart';

class Navigation {
  List<GetPage<dynamic>> routes = [
    GetPage(
      name: "/login",
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: "/dashboard",
      page: () => DashboardScreen(),
    ),
    GetPage(
      name: "/all-categories",
      page: () => const AllCategoriesScreen(),
    ),
    GetPage(
      name: "/all-products",
      page: () => const AllProductsScreen(),
    ),
    GetPage(
      name: "/van-categories",
      page: () => const VanCategoriesScreen(),
    ),
    GetPage(
      name: "/van-products",
      page: () => const VanProductsScreen(),
    ),
    GetPage(
      name: "/client-qr-code-scan",
      page: () => const ClientQrCodeScanScreen(),
    ),
    GetPage(
      name: "/clients",
      page: () => const ClientsScreen(),
    ),
    GetPage(
      name: "/create-new-client",
      page: () => const CreateNewClientScreen(),
    ),
    GetPage(
      name: "/create-new-order",
      page: () => const CreateNewOrderScreen(),
    ),
    GetPage(
      name: "/client-stock-screen",
      page: () => const ClientStockScreen(),
    ),
    GetPage(
      name: "/return-product",
      page: () => const ReturnProductScreen(),
    ),
  ];
  List<GetPage<dynamic>> getNavigationList() {
    return routes;
  }
}

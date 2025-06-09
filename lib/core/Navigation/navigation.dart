//! This is a navigator where routes for each screen are set
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/view/screens/allcategories/all_categories_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/allproducts/all_products_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/clientqrcodescan/client_qr_code_scan_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/clientstock/client_stock_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/createnewclient/create_new_client_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/createneworder/create_new_order_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/dashboard/dashboard_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/login/login_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/orderhistory/orders_history_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/returnproduct/return_product_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/vancategories/van_categories_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/vanproducts/van_products_screen.dart';
import 'package:inventory_management_system_mobile/view/screens/web/webdashboard/web_dashboard_screen.dart';

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
      name: "/web-dashboard",
      page: () => WebDashboardScreen(),
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
      name: "/create-new-client",
      page: () => const CreateNewClientScreen(),
    ),
    GetPage(
      name: "/create-new-order",
      page: () => CreateNewOrderScreen(),
    ),
    GetPage(
      name: "/client-stock-screen",
      page: () => const ClientStockScreen(),
    ),
    GetPage(
      name: "/return-product",
      page: () => const ReturnProductScreen(),
    ),
    GetPage(
      name: '/orders-history',
      page: () => const OrdersHistoryScreen(),
    ),
  ];
  List<GetPage<dynamic>> getNavigationList() {
    return routes;
  }
}

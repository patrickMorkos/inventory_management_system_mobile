import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:inventory_management_system_mobile/core/models/grid_items.dart';
import 'package:inventory_management_system_mobile/view/screens/web/categoriescontent/categories_content.dart';
import 'package:inventory_management_system_mobile/view/screens/web/clientstockcontent/client_stock_content.dart';
import 'package:inventory_management_system_mobile/view/screens/web/clientscontent/clients_content.dart';
import 'package:inventory_management_system_mobile/view/screens/web/orderscontent/orders_content.dart';
import 'package:inventory_management_system_mobile/view/screens/web/productscontent/products_content.dart';
import 'package:inventory_management_system_mobile/view/screens/web/salesmanscontent/salesmans_content.dart';
import 'package:inventory_management_system_mobile/view/screens/web/webdashboard/web_dashboard_tools.dart';

class WebDashboardScreen extends StatefulWidget {
  const WebDashboardScreen({super.key});

  @override
  State<WebDashboardScreen> createState() => _WebDashboardScreenState();
}

class _WebDashboardScreenState extends State<WebDashboardScreen> {
  //This variable is the list of the grid items in the drawer
  final List<GridItems> _gridItems = [
    GridItems(
      title: 'Categories',
      route: '/categories',
      icon: 'assets/images/category-icon.png',
      showCard: true,
      content: CategoriesContent(),
    ),
    GridItems(
      title: 'Products',
      route: '/products',
      icon: 'assets/images/product.png',
      showCard: true,
      content: ProductsContent(),
    ),
    GridItems(
      title: 'Clients',
      route: '/clients',
      icon: 'assets/images/parties.png',
      showCard: true,
      content: const ClientsContent(),
    ),
    GridItems(
      title: 'Salesmans',
      route: '/salesmans',
      icon: 'assets/images/salesman.jpg',
      showCard: true,
      content: const SalesmansContent(),
    ),
    GridItems(
      title: 'Clients stock',
      route: '/client-stock',
      icon: 'assets/images/warehouse-svgrepo-com.png',
      showCard: true,
      content: const ClientStockContent(),
    ),
    GridItems(
      title: 'Orders',
      route: '/orders',
      icon: 'assets/images/orders-history.png',
      showCard: true,
      content: OrdersContent(),
    ),
  ];

  // For navigation highlight (index of the selected menu item).
  int _selectedIndex = 0;

  // ---------------------------------------------------------------------------
  // WIDGETS
  // ---------------------------------------------------------------------------
  Widget buildSidebar() {
    return Container(
      width: 220,
      height: double.infinity,
      color: kMainColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Text(
                'Inventory\nAdmin',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Menu items
            ...List.generate(_gridItems.length, (index) {
              final item = _gridItems[index];
              return SidebarTile(
                title: item.title,
                iconPath: item.icon,
                selected: _selectedIndex == index,
                onTap: () {
                  setState(() => _selectedIndex = index);
                  // Get.toNamed(item.route);
                },
              );
            }),
            const Spacer(),
            SidebarTile(
              title: 'Logout',
              icon: Icons.logout, // Using Material icon for logout.
              selected: false,
              onTap: () => Get.offAllNamed('/login'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget buildTopBar() {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Text(
            _gridItems[_selectedIndex].title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: kMainColor,
            ),
          ),
          const Spacer(),
          // Placeholder for possible actions / user avatar
          InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: () => Get.toNamed('/profile'),
            child: const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                  'https://static.vecteezy.com/system/resources/thumbnails/026/497/734/small_2x/businessman-on-isolated-png.png'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDashboardContent() {
    final content = _gridItems[_selectedIndex].content;
    return content ?? const Center(child: Text('No content available.'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          //SIDEBAR
          buildSidebar(),

          //MAIN CONTENT AREA
          Expanded(
            child: Column(
              children: [
                buildTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: buildDashboardContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

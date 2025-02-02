//! Dashboard Screem UI
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventory_management_system_mobile/core/controllers/logged_in_user_controller.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:inventory_management_system_mobile/core/models/grid_items.dart';
import 'package:inventory_management_system_mobile/view/widgets/dashboard_grid_card.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});
  //******************************************************************VARIABLES
  //This variable is for the logged in user data
  final LoggedInUserController loggedInUserController =
      Get.put(LoggedInUserController());

  //This variable is for each grid button color
  final List<Color> color = [
    const Color(0xffEDDBFF),
    const Color(0xffBFFFEF),
    const Color(0xffFFD6E2),
    const Color(0xffBBFFC1),
    const Color(0xffFFE4C1),
    const Color(0xffFFD6E2),
    const Color(0xffEBD7FF),
    const Color(0xffD9EEFF),
    const Color(0xffFFE4C1),
    const Color(0xffD9EEFF),
  ];

  List<GridItems> _getCashVanSalesmanIcons() {
    final userTypeId = loggedInUserController.loggedInUser.value.userTypeId;

    return [
      GridItems(
        title: "All Categories",
        route: 'all-categories',
        showCard: true,
        icon: 'assets/images/category-icon.png',
      ),
      GridItems(
        title: "All Products",
        route: 'all-products',
        showCard: true,
        icon: 'assets/images/product.png',
      ),
      GridItems(
        title: "Van Categories",
        route: 'van-categories',
        showCard: userTypeId == 3 ? false : true,
        icon: 'assets/images/sales.png',
      ),
      GridItems(
        title: "Van Products",
        route: 'van-products',
        showCard: userTypeId == 3 ? false : true,
        icon: 'assets/images/delivery-van-icon.png',
      ),
      GridItems(
        title: "Client QR code scan",
        route: 'client-qr-code-scan',
        showCard: true,
        icon: 'assets/images/qr-code-scan-icon.png',
      ),
      GridItems(
        title: "Clients",
        route: 'clients',
        showCard: true,
        icon: 'assets/images/parties.png',
      ),
      GridItems(
        title: "Create New Client",
        route: 'create-new-client',
        showCard: true,
        icon: 'assets/images/new-client.png',
      ),
      GridItems(
        title: "Order Cart",
        route: 'create-new-order',
        showCard: true,
        icon: 'assets/images/create-receipt-doc.png',
      ),
      GridItems(
        title: "Client Stock Screen",
        route: 'client-stock-screen',
        showCard: true,
        icon: 'assets/images/warehouse-svgrepo-com.png',
      ),
      GridItems(
        title: "Return Product",
        route: 'return-product',
        showCard: true,
        icon: 'assets/images/return-product-icon.png',
      ),
    ];
  }

  //******************************************************************FUNCTIONS
  //This function render the profile picture
  Widget renderProfilePicture() {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: GestureDetector(
        onTap: () {
          if (kDebugMode) {
            //TODO - implement profile
          }
        },
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kBorderColorTextField),
          ),
          child: ClipOval(
            child: Image.network(
              'https://static.vecteezy.com/system/resources/thumbnails/026/497/734/small_2x/businessman-on-isolated-png.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.person,
                  color: Colors.grey,
                  size: 24,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  //This functions renders the salesman full name
  Widget renderFullName() {
    String salesmanName =
        '${loggedInUserController.loggedInUser.value.firstName} ${loggedInUserController.loggedInUser.value.lastName}';

    return Text(
      salesmanName,
      style: GoogleFonts.poppins(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  //This function renders the dashboard header
  Widget renderDashboardHeader() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        color: kDarkWhite,
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          top: 10,
          bottom: 10,
        ),
        child: Row(
          children: [
            Text(
              "Dashboard Overview",
              style: kTextStyle.copyWith(
                fontWeight: FontWeight.bold,
                color: kTitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //This function renders the dashboard body
  Widget renderDashboardBody() {
    final visibleItems =
        _getCashVanSalesmanIcons().where((item) => item.showCard).toList();

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            //Grid of screens
            Container(
              padding: const EdgeInsets.all(10.0),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                childAspectRatio: 1.0,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
                crossAxisCount: 3,
                children: List.generate(
                  visibleItems.length,
                  (index) => DashboardGridCards(
                    gridItems: visibleItems[index],
                    color: color[index],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kMainColor,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: kMainColor,
          //Salesman Profile picture
          leading: renderProfilePicture(),

          //Salesman first name and last naame
          title: renderFullName(),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(25),
                topLeft: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                //Dashboard Header
                renderDashboardHeader(),

                //Dashboard body
                renderDashboardBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

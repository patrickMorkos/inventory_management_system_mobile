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

  //This variable is a list of the icon of cash van salesman
  final List<GridItems> cashVanSalesmanIcons = [
    GridItems(
      title: "All Categories",
      route: 'all-categories',
      icon: 'images/category-icon.svg',
    ),
    GridItems(
      title: "All Products",
      route: 'all-products',
      icon: 'images/product.svg',
    ),
    GridItems(
      title: "Van Categories",
      route: 'van-categories',
      icon: 'images/sales.svg',
    ),
    GridItems(
      title: "Van Products",
      route: 'van-products',
      icon: 'images/delivery-van-icon.svg',
    ),
    GridItems(
      title: "Client QR code scan",
      route: 'client-qr-code-scan',
      icon: 'images/qr-code-scan-icon.svg',
    ),
    GridItems(
      title: "Clients",
      route: 'clients',
      icon: 'images/parties.svg',
    ),
    GridItems(
      title: "Create New Client",
      route: 'create-new-client',
      icon: 'images/new-client.svg',
    ),
    GridItems(
      title: "Create New Order",
      route: 'create-new-order',
      icon: 'images/create-receipt-doc.svg',
    ),
    GridItems(
      title: "Client Stock Screen",
      route: 'client-stock-screen',
      icon: 'images/warehouse-svgrepo-com.svg',
    ),
    GridItems(
      title: "Return Product",
      route: 'return-product',
      icon: 'images/return-product-icon.svg',
    ),
  ];

  //This variable is a list of the icon of marchandise salesman
  final List<GridItems> marchandiseSalesmanIcons = [
    GridItems(
      title: "All Categories",
      route: 'all-categories',
      icon: 'images/category-icon.svg',
    ),
    GridItems(
      title: "All Products",
      route: 'all-products',
      icon: 'images/product.svg',
    ),
    GridItems(
      title: "Client QR code scan",
      route: 'client-qr-code-scan',
      icon: 'images/qr-code-scan-icon.svg',
    ),
    GridItems(
      title: "Clients",
      route: 'clients',
      icon: 'images/parties.svg',
    ),
    GridItems(
      title: "Create New Client",
      route: 'create-new-client',
      icon: 'images/new-client.svg',
    ),
    GridItems(
      title: "Create New Order",
      route: 'create-new-order',
      icon: 'images/create-receipt-doc.svg',
    ),
    GridItems(
      title: "Client Stock Screen",
      route: 'client-stock-screen',
      icon: 'images/warehouse-svgrepo-com.svg',
    ),
    GridItems(
      title: "Return Product",
      route: 'return-product',
      icon: 'images/return-product-icon.svg',
    ),
  ];

  //******************************************************************FUNCTIONS
  //This function render the profile picture
  Widget renderProfilePicture() {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: GestureDetector(
        onTap: () {
          if (kDebugMode) {
            //TODO - implement profile
            print("Profile");
          }
        },
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: NetworkImage(
                'https://static.vecteezy.com/system/resources/thumbnails/026/497/734/small_2x/businessman-on-isolated-png.png',
              ),
              fit: BoxFit.cover,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: kBorderColorTextField),
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
    int userType = loggedInUserController.loggedInUser.value.userTypeId;

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
                  userType == 3
                      ? marchandiseSalesmanIcons.length
                      : cashVanSalesmanIcons.length,
                  (index) => DashboardGridCards(
                    gridItems: userType == 3
                        ? marchandiseSalesmanIcons[index]
                        : cashVanSalesmanIcons[index],
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

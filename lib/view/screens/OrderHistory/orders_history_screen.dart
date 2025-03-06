import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management_system_mobile/core/controllers/client_controller.dart';
import 'package:inventory_management_system_mobile/core/controllers/logged_in_user_controller.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:inventory_management_system_mobile/data/api_service.dart';
import 'package:inventory_management_system_mobile/view/screens/ClientQrCodeScan/sale_products_dialog.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  final LoggedInUserController loggedInUserController =
      Get.put(LoggedInUserController());

  final ClientController clientController = Get.put(ClientController());

  List<dynamic> previousOrders = [];

  @override
  void initState() {
    super.initState();
    fetchOrdersHistory();
  }

  Future<void> fetchOrdersHistory() async {
    int salesmanId = loggedInUserController.loggedInUser.value.id;
    int clientId = clientController.clientInfo["id"];

    if (clientId == -1) {
      setState(() {
        previousOrders = []; // Clear previous data
      });
      return; // Don't fetch orders, just show a message
    }

    await getRequest(
      path: "/api/sale/get-all-client-sales/$salesmanId?client_id=$clientId",
      requireToken: true,
    ).then((value) {
      setState(() {
        previousOrders = value;
      });
    });
  }

  void showSaleProductsDialog(BuildContext context, List<dynamic> products) {
    showDialog(
      context: context,
      builder: (context) {
        return SaleProductsDialog(products: products);
      },
    );
  }

  // Function to format date
  String formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('dd-MMM-yyyy hh:mm a').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  Widget renderOrdersList(sw) {
    final usdLbpRate = loggedInUserController.loggedInUser.value.usdLbpRate;

    if (clientController.clientInfo["id"] == -1) {
      return Expanded(
        child: Center(
          child: Text(
            "You need to check in to a client first.",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[700], // Same as "No previous orders found."
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: previousOrders.isEmpty
              ? const Center(
                  child: Text(
                    "No previous orders found.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Column(
                  children: previousOrders.map((order) {
                    final usdFormatter = NumberFormat("#,##0.00", "en_US");
                    final lbpFormatter = NumberFormat("#,###", "en_US");

                    String formattedPriceUsd =
                        usdFormatter.format(order["total_price_usd"]);
                    String formattedPriceLbp = lbpFormatter
                        .format(order["total_price_usd"] * usdLbpRate);

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        onTap: () {
                          showSaleProductsDialog(context, order['products']);
                        },
                        leading: Icon(Icons.receipt, color: kMainColor),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order #${order["id"]}",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Total: \$ $formattedPriceUsd /  LBP $formattedPriceLbp",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "Issue Date: ${formatDate(order["issue_date"])}",
                                  style: GoogleFonts.poppins(
                                    fontSize: sw * 0.025,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: kMainColor,
        appBar: AppBar(
          backgroundColor: kMainColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Orders History",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Container(
          alignment: Alignment.topCenter,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              topLeft: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              renderOrdersList(sw),
            ],
          ),
        ),
      ),
    );
  }
}

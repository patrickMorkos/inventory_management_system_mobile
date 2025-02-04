import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventory_management_system_mobile/core/controllers/client_controller.dart';
import 'package:inventory_management_system_mobile/core/controllers/logged_in_user_controller.dart';
import 'package:inventory_management_system_mobile/core/controllers/van_products_controller.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:inventory_management_system_mobile/data/api_service.dart';
import 'package:inventory_management_system_mobile/view/screens/ClientQrCodeScan/sale_products_dialog.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';

class ClientQrCodeScanScreen extends StatefulWidget {
  const ClientQrCodeScanScreen({super.key});

  @override
  State<ClientQrCodeScanScreen> createState() => _ClientQrCodeScanScreenState();
}

class _ClientQrCodeScanScreenState extends State<ClientQrCodeScanScreen> {
  //******************************************************************VARIABLES

  //This variable is the client controller
  final ClientController clientController = Get.put(ClientController());

  //This variable is the logged in user controller
  final LoggedInUserController loggedInUserController =
      Get.put(LoggedInUserController());

  //This variable is used to store the client orders
  List<dynamic> clientOrders = [];

  //This variable is the vanProductsController
  final VanProductsController vanProductsController =
      Get.put(VanProductsController());

  //******************************************************************FUNCTIONS

  @override
  void initState() {
    if (clientController.clientInfo["id"] != -1) {
      fetchClientOrders(clientController.clientInfo["id"]);
    }
    super.initState();
  }

  void showSaleProductsDialog(BuildContext context, List<dynamic> products) {
    showDialog(
      context: context,
      builder: (context) {
        return SaleProductsDialog(
          products: products,
        );
      },
    );
  }

  //This function renders the app bar
  AppBar renderAppBar() {
    return AppBar(
      backgroundColor: kMainColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: const Icon(
        Icons.arrow_back,
        color: Colors.white,
      ).onTap(() => Get.toNamed("/dashboard")),
      title: Text(
        "Scan QR Code",
        style: GoogleFonts.poppins(
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  //This function gets the client from the QR code
  Future<void> getClientFromQrCode(String qrCode) async {
    int clientId = qrCode.toInt();

    if (clientController.clientInfo["id"] != -1) {
      // If already checked in, perform check-out
      await postRequest(
        path:
            "/api/salesman-client-visits/client-check-out/${loggedInUserController.loggedInUser.value.id}?client_id=$clientId",
        body: {},
        requireToken: true,
      ).then((value) {
        setState(() {
          clientOrders.clear();
          clientController.setClientInfo(
            {
              "id": -1,
            },
          );
        });
      });
    } else {
      // Get client info
      await getRequest(
        path: "/api/client/get-client/$clientId",
        requireToken: true,
      ).then((value) {
        clientController.setClientInfo(value);
        fetchClientOrders(clientId);
      });

      // Perform check-in
      await postRequest(
        path:
            "/api/salesman-client-visits/client-check-in/${loggedInUserController.loggedInUser.value.id}?client_id=$clientId",
        body: {},
        requireToken: true,
      );
    }

    await getRequest(
      path:
          "/api/van-products/get-all-van-products/${loggedInUserController.loggedInUser.value.id}?client_id=$clientId",
      requireToken: true,
    ).then((value) {
      vanProductsController.setVanProductsInfo(value);
    });
  }

  //This function fetches the client orders
  Future<void> fetchClientOrders(int clientId) async {
    await getRequest(
      path: "/api/sale/get-all-client-sales/1?client_id=$clientId",
      requireToken: true,
    ).then((value) {
      setState(() {
        clientOrders = value;
        clientController.clientInfo["sales"] = clientOrders;
      });
    });
  }

  // Function to format the date
  String formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('dd-MMM-yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  // Render client orders listing
  Widget renderClientOrdersListing(sw) {
    final usdLbpRate = loggedInUserController.loggedInUser.value.usdLbpRate;

    if (clientController.clientInfo["sales"] != null) {
      clientOrders = clientController.clientInfo["sales"];
    }
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: clientOrders.isEmpty
              ? const Center(
                  child: Text("No previous orders found."),
                )
              : Column(
                  children: clientOrders.map((order) {
                    final formatter = NumberFormat("#,###", "en_US");
                    String formattedPriceUsd =
                        formatter.format(order["total_price_usd"]);
                    String formattedPriceLbp =
                        formatter.format(order["total_price_usd"] * usdLbpRate);
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
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 5),
                                Text(
                                  "Issue Date: ${formatDate(order["issue_date"])}",
                                  style:
                                      GoogleFonts.poppins(fontSize: sw * 0.025),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.timer,
                                    size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 5),
                                Text(
                                  "Due Date: ${order["due_date"] != null ? formatDate(order["due_date"]) : "Pending"}",
                                  style:
                                      GoogleFonts.poppins(fontSize: sw * 0.025),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            // Sale Type Chip
                            Row(
                              children: [
                                Icon(Icons.storefront,
                                    size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Chip(
                                    backgroundColor:
                                        order["SaleType"]["id"] == 1
                                            ? Colors.green[100]
                                            : Colors.blue[100],
                                    label: Text(
                                      order["SaleType"]["sale_type_name"],
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: order["SaleType"]["id"] == 1
                                            ? Colors.green[800]
                                            : Colors.blue[800],
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: -2),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ),
    );
  }

  //This function renders the scan QR code button
  Widget renderScanQrCodeButton(sw, sh) {
    return Container(
      width: sw * 0.85,
      height: sh * 0.2,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kMainColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () async {
            String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
              "#ff6666",
              "Cancel",
              true,
              ScanMode.BARCODE,
            );
            if (barcodeScanRes != "-1") {
              getClientFromQrCode(barcodeScanRes);
            }
          },
          child: Text(
            clientController.clientInfo["id"] != -1
                ? "Check-Out"
                : "Scan QR Code",
            style: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  //Render client info
  Widget renderClientInfo(sw, sh) {
    return clientController.clientInfo["id"] != -1
        ? Container(
            width: sw * 0.85,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You checked-in for client:",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "${clientController.clientInfo["first_name"]} ${clientController.clientInfo["last_name"]}",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        : SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    //This variable is the screen width
    double sw = MediaQuery.of(context).size.width;

    //This variable is the screen height
    double sh = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: kMainColor,
        appBar: renderAppBar(),
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              renderScanQrCodeButton(sw, sh),
              const SizedBox(height: 20),
              renderClientInfo(sw, sh),
              const SizedBox(height: 20),
              renderClientOrdersListing(sw),
            ],
          ),
        ),
      ),
    );
  }
}

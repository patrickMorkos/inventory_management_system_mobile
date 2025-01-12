import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventory_management_system_mobile/core/controllers/client_controller.dart';
import 'package:inventory_management_system_mobile/core/controllers/logged_in_user_controller.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:inventory_management_system_mobile/data/api_service.dart';
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

  //******************************************************************FUNCTIONS

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
  Widget renderClientOrdersListing() {
    if (clientController.clientInfo["sales"] != null) {
      clientOrders = clientController.clientInfo["sales"];
    }
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: clientController.clientInfo["sales"] == null
              ? const Center(
                  child: Text("No previous orders found."),
                )
              : Column(
                  children: clientOrders.map((order) {
                    return ListTile(
                      onTap: () {
                        print("See sale product and add to order");
                      },
                      leading: Icon(Icons.receipt, color: kMainColor),
                      title: Text("Order #${order["id"]}"),
                      subtitle: Text("Total: \$${order["total_price_usd"]}"),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Issue Date: ${formatDate(order["issue_date"])}",
                          ),
                          Text(
                            "Due Date: ${order["due_date"] != null ? formatDate(order["due_date"]) : "Pending"}",
                          ),
                        ],
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
        color: grey.withOpacity(0.2),
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
              getClientFromQrCode(4.toString());
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
              color: grey.withOpacity(0.2),
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
              renderClientOrdersListing(),
            ],
          ),
        ),
      ),
    );
  }
}

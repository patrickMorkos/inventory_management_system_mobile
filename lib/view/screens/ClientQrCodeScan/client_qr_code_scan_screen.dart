import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventory_management_system_mobile/core/controllers/client_controller.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:inventory_management_system_mobile/data/api_service.dart';
import 'package:nb_utils/nb_utils.dart';

class ClientQrCodeScanScreen extends StatefulWidget {
  const ClientQrCodeScanScreen({super.key});

  @override
  State<ClientQrCodeScanScreen> createState() => _ClientQrCodeScanScreenState();
}

class _ClientQrCodeScanScreenState extends State<ClientQrCodeScanScreen> {
  //******************************************************************VARIABLES

  //This variable is the client controller
  final ClientController clientController = Get.put(ClientController());

  //This variable is a flag to show the cllient info or not
  bool flag = false;

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
    int id = qrCode.toInt();
    await getRequest(
      path: "/api/client/get-client/$id",
      requireToken: true,
    ).then((value) {
      //Todo : continue here
      clientController.setClientInfo(value);
      setState(() {
        flag = true;
      });
    });
  }

  //This function renders the scan QR code button
  Widget renderScanQrCodeButton(sw, sh) {
    return Container(
      width: sw * 0.85,
      height: sh * 0.35,
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
            getClientFromQrCode(barcodeScanRes);
            print("barcodeScanRes===>$barcodeScanRes");
          },
          child: Text(
            "Scan QR Code",
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
    return Container(
      width: sw * 0.85,
      height: sh * 0.35,
      decoration: BoxDecoration(
        color: grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: flag == true
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You checked-in for client:",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "${clientController.clientInfo["first_name"]} ${clientController.clientInfo["last_name"]}",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          : SizedBox(),
    );
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //Scan QR code button
              renderClientInfo(sw, sh),
              renderScanQrCodeButton(sw, sh),
            ],
          ),
        ),
      ),
    );
  }
}

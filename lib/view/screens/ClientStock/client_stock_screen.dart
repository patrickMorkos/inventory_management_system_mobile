import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:inventory_management_system_mobile/core/controllers/client_controller.dart';
import 'package:inventory_management_system_mobile/core/controllers/client_stock_controller.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:inventory_management_system_mobile/view/widgets/empty_screen_widget.dart';
import 'package:nb_utils/nb_utils.dart';

class ClientStockScreen extends StatefulWidget {
  const ClientStockScreen({super.key});

  @override
  State<ClientStockScreen> createState() => _ClientStockScreenState();
}

class _ClientStockScreenState extends State<ClientStockScreen> {
  // Variables
  final TextEditingController searchEditController = TextEditingController();
  final ClientStockController clientStockController =
      Get.put(ClientStockController());
  List<dynamic> searchedProductsList = [];

  //This variable is the client controller
  final ClientController clientController = Get.put(ClientController());

  @override
  void initState() {
    super.initState();
    if (clientController.clientInfo["id"] != -1) {
      getClientStockProducts();
    }
  }

  Future<void> getClientStockProducts() async {
    await clientStockController
        .fetchClientStockProducts(clientController.clientInfo["id"]);
    setState(() {
      searchedProductsList = clientStockController.clientStockProducts;
    });
  }

  Future<void> updateProductBoxQuantity(int productId, int boxQuantity) async {
    await clientStockController.updateProductBoxQuantity(
        clientController.clientInfo["id"], productId, boxQuantity);
    getClientStockProducts();
  }

  Future<void> deleteProduct(int productId) async {
    await clientStockController.deleteProduct(
        clientController.clientInfo["id"], productId);
    getClientStockProducts();
  }

  Future<void> openBarcodeScanner() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancel",
        true,
        ScanMode.BARCODE,
      );
    } on PlatformException {
      barcodeScanRes = "Failed to get platform version.";
    }
    if (!mounted) return;
    searchProduct(barcodeScanRes);
  }

  void searchProduct(String query) {
    setState(() {
      if (query.isEmpty) {
        searchedProductsList = clientStockController.clientStockProducts;
      } else {
        searchedProductsList = clientStockController.clientStockProducts
            .where((product) => product["Product"]["name"]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

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
        "Client Stock Products",
        style: GoogleFonts.poppins(color: Colors.white),
      ),
      centerTitle: true,
    );
  }

  Widget renderSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
      child: TextField(
        controller: searchEditController,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(8.0),
          labelText: "Search Product",
          hintText: "Enter product name or scan barcode",
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IntrinsicWidth(
            child: Row(
              children: [
                InkWell(
                  onTap: openBarcodeScanner,
                  child: const Icon(Icons.qr_code_scanner, color: kMainColor),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: kMainColor),
                  onPressed: () {
                    searchEditController.clear();
                    searchProduct("");
                  },
                ),
              ],
            ),
          ),
        ),
        onChanged: searchProduct,
      ),
    );
  }

  Widget renderProductList(sw) {
    if (searchedProductsList.isEmpty) {
      return const Center(child: EmptyScreenWidget());
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: searchedProductsList.length,
      itemBuilder: (context, index) {
        final product = searchedProductsList[index];

        return StatefulBuilder(
          // 👈 Rebuilds only this item in the list
          builder: (context, setState) {
            FocusNode qtyFocusNode = FocusNode(); // 👈 Track focus
            int boxQuantity = product["box_quantity"]; // 👈 Local state for UI updates

            return Card(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    product["Product"]["image_url"] ?? "",
                  ),
                  onBackgroundImageError: (_, __) =>
                      const Icon(Icons.broken_image),
                ),
                title: Text(
                  product["Product"]["name"] ?? "",
                  style: TextStyle(fontSize: sw * 0.03),
                ),
                subtitle: Text(
                  "Brand: ${product["Product"]["Brand"]["brand_name"] ?? ""}",
                  style: TextStyle(fontSize: sw * 0.03),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Wrap InputQty with Focus to detect when user taps outside
                    Focus(
                      focusNode: qtyFocusNode,
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          // 👈 Only call API when user exits text field
                          updateProductBoxQuantity(
                              product["Product"]["id"], boxQuantity);
                        }
                      },
                      child: InputQty(
                        maxVal: product["box_quantity"] +
                            100, // Set an appropriate max limit
                        decoration: QtyDecorationProps(
                          btnColor: kMainColor, // Match the UI theme
                          fillColor: Colors.white,
                        ),
                        initVal: boxQuantity
                            .toDouble(), // Initialize with current box quantity
                        onQtyChanged: (value) {
                          if (value is double || value is int) {
                            setState(() {
                              // 👈 UI updates instantly when changing box quantity
                              boxQuantity = value.toInt();
                            });
                            updateProductBoxQuantity(product["Product"]["id"],
                                boxQuantity); // 👈 Ensure API is always called
                          }
                        },
                      ),
                    ),
                    IconButton(
                      iconSize: sw * 0.05,
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteProduct(product["Product"]["id"]),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //This variable is the screen width
    double sw = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: kMainColor,
        appBar: renderAppBar(),
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              renderSearchBar(),
              const SizedBox(height: 10.0),
              Expanded(child: renderProductList(sw)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.toNamed('/all-products', arguments: {"fromClientStock": true});
          },
          backgroundColor: kMainColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

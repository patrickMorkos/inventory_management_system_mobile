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

  Future<void> updateProductQuantities(
      int productId, int boxQuantity, int itemQuantity) async {
    await clientStockController.updateProductQuantities(
        clientController.clientInfo["id"],
        productId,
        boxQuantity,
        itemQuantity);
    setState(() {
      // Find the product in the local list and update its values
      for (var product in searchedProductsList) {
        if (product["Product"]["id"] == productId) {
          product["box_quantity"] = boxQuantity;
          product["items_quantity"] = itemQuantity;
        }
      }
    });
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
          builder: (context, setState) {
            FocusNode boxQtyFocusNode = FocusNode();
            FocusNode itemQtyFocusNode = FocusNode();

            int boxQuantity = product["box_quantity"] ?? 0;
            int itemQuantity = product["items_quantity"] ?? 0;

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
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Box Quantity Field
                    Focus(
                      focusNode: boxQtyFocusNode,
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          updateProductQuantities(product["Product"]["id"],
                              boxQuantity, itemQuantity);
                        }
                      },
                      child: Row(
                        children: [
                          Text("Box: ", style: TextStyle(fontSize: sw * 0.03)),
                          SizedBox(
                            width: 50,
                            child: TextFormField(
                              initialValue: boxQuantity.toString(),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(5),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  boxQuantity = int.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5), // Spacer

                    // Item Quantity Field
                    Focus(
                      focusNode: itemQtyFocusNode,
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          updateProductQuantities(product["Product"]["id"],
                              boxQuantity, itemQuantity);
                        }
                      },
                      child: Row(
                        children: [
                          Text("Item: ", style: TextStyle(fontSize: sw * 0.03)),
                          SizedBox(
                            width: 50,
                            child: TextFormField(
                              initialValue: itemQuantity.toString(),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(5),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  itemQuantity = int.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
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

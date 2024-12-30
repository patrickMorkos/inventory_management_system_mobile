//! All Products screen UI
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventory_management_system_mobile/core/controllers/client_controller.dart';
import 'package:inventory_management_system_mobile/core/controllers/logged_in_user_controller.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:inventory_management_system_mobile/data/api_service.dart';
import 'package:inventory_management_system_mobile/view/screens/AllProducts/all_products_screen_tools.dart';
import 'package:inventory_management_system_mobile/view/screens/VanProducts/van_products_screen_tools.dart';
import 'package:inventory_management_system_mobile/view/widgets/empty_screen_widget.dart';
import 'package:nb_utils/nb_utils.dart';

class VanProductsScreen extends StatefulWidget {
  const VanProductsScreen({super.key});

  @override
  State<VanProductsScreen> createState() => _VanProductsScreenState();
}

class _VanProductsScreenState extends State<VanProductsScreen> {
  //******************************************************************VARIABLES

  //This variable is the list of all the products that will be listed
  List<dynamic> productsList = [];

  //This variable is a text editing controller for the search bar
  TextEditingController searchEditController = TextEditingController();

  //This variable is the list of all the products after search
  List<dynamic> searchedProductsList = [];

  //This variable is the value entered for search
  String searchedProduct = "";

  //This variable is the logged in user
  final LoggedInUserController loggedInUserController =
      Get.put(LoggedInUserController());

  //This variable is the category id
  int categoryId = -1;

  //This function is the client controller
  final ClientController clientController = Get.put(ClientController());

  //******************************************************************FUNCTIONS

  //This function call the get van products API
  Future<void> getVanProducts() async {
    await getRequest(
      path:
          "/api/van-products/get-all-van-products/${loggedInUserController.loggedInUser.value.id}",
      requireToken: true,
    ).then((value) {
      setState(() {
        productsList = value;
        searchedProductsList = productsList;
      });
    });
    if (Get.arguments != null) {
      final arguments = Get.arguments as Map<String, dynamic>;
      categoryId = arguments["category_id"];
      filterProductsList(categoryId);
    }
  }

  @override
  void initState() {
    super.initState();
    getVanProducts();
  }

  //This function filters the products list
  void filterProductsList(int categoryId) {
    setState(() {
      searchedProductsList = productsList.where((element) {
        return element["Product"]["Category"]["id"] == categoryId;
      }).toList();
    });
  }

  //This function renders the products list
  Widget renderProductsListing(sw, sh) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: getProductsCards(sw, sh),
          ),
        ),
      ),
    );
  }

  //This function returns the products cards list
  List<Widget> getProductsCards(sw,sh) {
    List<Widget> tmp = [];
    if (searchedProductsList.isEmpty) {
      tmp.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 60),
            child: EmptyScreenWidget(),
          ),
        ),
      );
    } else {
      for (var element in searchedProductsList) {
        tmp.add(
          ListTile(
            onTap: () {
              openProductDetailsDialog(
                context,
                sw,
                sh,
                element,
                clientController.clientInfo,
              );
            },
            leading: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kBorderColorTextField),
              ),
              child: ClipOval(
                child: Image.network(
                  element["Product"]["image_url"] ?? "",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 30,
                    );
                  },
                ),
              ),
            ),
            title: Text(
              element["Product"]["name"] ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text("Brand: ${element["Product"]["brand"] ?? ""}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Quantity: ${element["quantity"] ?? ""}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      "Price: \$${element["Product"]["ProductPrice"]["pricea1"] ?? ""}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        tmp.add(
          const SizedBox(
            height: 20,
            child: Divider(),
          ),
        );
      }
    }

    return tmp;
  }

  // This function open the barcode scanner
  Future<void> openBarcodeScanner(sw, sh) async {
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
    searchProduct(barcodeScanRes, sw, sh);
  }

  //This function search for the product barcode inside the list of products
  void searchProduct(String barcode, sw, sh) {
    //Condition if the barcode scanning is canceled
    if (barcode == "-1") {
      searchedProductsList = productsList;
    }

    //Condition if the scanned barcode is found
    if (searchedProductsList.any((element) => element["barcode"] == barcode)) {
      setState(() {
        searchedProductsList = productsList.where((element) {
          return element["barcode"]
              .toString()
              .toLowerCase()
              .contains(barcode.toLowerCase());
        }).toList();
      });
    } else {
      searchedProductsList = productsList;
      openDialog(context, sw, sh, [], barcode);
    }
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
        "Van Products List",
        style: GoogleFonts.poppins(
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  //This function renders the search bar
  Widget renderSearchBar(sw, sh) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
      child: AppTextField(
        controller: searchEditController,
        textFieldType: TextFieldType.NAME,
        onChanged: (value) {
          setState(() {
            searchedProductsList = productsList.where((element) {
              return element["product_name"]
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase());
            }).toList();
          });
          if (value.isEmpty) {
            setState(() {
              searchedProductsList = productsList;
            });
          }
          setState(() {
            searchedProduct = value;
          });
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelText: "Product Name",
          hintText: "Enter Product Name",
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IntrinsicWidth(
            child: Row(
              children: [
                InkWell(
                  onTap: () => {
                    if (isMobile) openBarcodeScanner(sw, sh),
                  },
                  child: const ImageIcon(
                    AssetImage("assets/images/Scanbarcode.png"),
                    color: kMainColor,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      searchedProductsList = productsList;
                      searchEditController.text = "";
                    });
                  },
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: kMainColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20.0),
              //Search bar
              renderSearchBar(sw, sh),

              //Products list
              renderProductsListing(sw, sh)
            ],
          ),
        ),
      ),
    );
  }
}

//! All Products screen UI
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:inventory_management_system_mobile/core/controllers/client_controller.dart';
import 'package:inventory_management_system_mobile/core/controllers/logged_in_user_controller.dart';
import 'package:inventory_management_system_mobile/core/controllers/order_controller.dart';
import 'package:inventory_management_system_mobile/core/controllers/van_products_controller.dart';
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

  //This variable is the quantity of the product
  int quantity = 1;

  //This variable is the order controller
  final OrderController orderController = Get.put(OrderController());

  //This variable is the van products controller
  final VanProductsController vanProductsController =
      Get.put(VanProductsController());

  //******************************************************************FUNCTIONS

  //This function renders the add product to cart button
  Widget renderAddProductToCartButton(
    context,
    sw,
    sh,
    product,
    clientInfo,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: sh / 50,
      ),
      child: ElevatedButton(
        onPressed: () {
          orderController.addProductToOrder(product["Product"], quantity);
          vanProductsController.deductQuantity(
            product["Product"]["id"],
            quantity,
          );
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Add to Cart',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  //This function renders the product quantity
  Widget renderQuantityPickUp(sh, product) {
    return Container(
      padding: EdgeInsets.only(
        top: sh / 50,
      ),
      child: InputQty(
        maxVal: product["quantity"],
        decoration: QtyDecorationProps(
          btnColor: kMainColor,
          fillColor: Colors.white,
        ),
        onQtyChanged: (value) {
          setState(() {
            quantity = value.toString().toInt();
          });
        },
      ),
    );
  }

  void openProductDetailsDialog(context, sw, sh, product, clientInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kMainColor,
          insetPadding: EdgeInsets.zero,
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.white,
            ),
          ),
          actions: [
            SizedBox(
              // width: sw * 0.8,
              height: sh * 0.5,
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      //Alert dialog Header
                      renderProductDescriptionHeader(sh),

                      //Product Image
                      renderProductImage(sw, sh, product),

                      //Product Name
                      renderProductItems(
                        sw,
                        sh,
                        "Name",
                        product["Product"]["name"] ?? "",
                      ),

                      //Product Brand
                      renderProductItems(
                        sw,
                        sh,
                        "Brand",
                        product["Product"]["Brand"]["brand_name"] ?? "",
                      ),

                      //Product Category
                      renderProductItems(
                        sw,
                        sh,
                        "Category",
                        product["Product"]["Category"]["category_name"] ?? "",
                      ),

                      //Product Quantity
                      renderProductItems(
                        sw,
                        sh,
                        "Quantity",
                        product["quantity"] ?? "",
                      ),

                      //Product Price
                      renderProductItems(
                        sw,
                        sh,
                        "Price",
                        product["Product"]["ProductPrice"]["pricea1"] != null
                            ? "\$${product["Product"]["ProductPrice"]["pricea1"]}"
                            : "",
                      ),

                      //Quantity pick-up
                      if (clientInfo["id"] != -1)
                        renderQuantityPickUp(sh, product),

                      //Add product to cart
                      if (clientInfo["id"] != -1)
                        renderAddProductToCartButton(
                          context,
                          sw,
                          sh,
                          product,
                          clientInfo,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  //This function call the get van products API
  Future<void> getVanProducts() async {
    await getRequest(
      path:
          "/api/van-products/get-all-van-products/${loggedInUserController.loggedInUser.value.id}",
      requireToken: true,
    ).then((value) {
      vanProductsController.setVanProductsInfo(value);
      setState(() {
        searchedProductsList = vanProductsController.vanProductsList;
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
    if (clientController.clientInfo["id"] == -1) {
      getVanProducts();
    } else {
      searchedProductsList = vanProductsController.vanProductsList;
      if (Get.arguments != null) {
        final arguments = Get.arguments as Map<String, dynamic>;
        categoryId = arguments["category_id"];
        filterProductsList(categoryId);
      }
    }
  }

  //This function filters the products list
  void filterProductsList(int categoryId) {
    setState(() {
      searchedProductsList =
          vanProductsController.vanProductsList.where((element) {
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
  List<Widget> getProductsCards(sw, sh) {
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
            subtitle: Text(
              "Brand: ${element["Product"]["Brand"]["brand_name"] ?? ""}",
            ),
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
      searchedProductsList = vanProductsController.vanProductsList;
    }

    //Condition if the scanned barcode is found
    if (searchedProductsList.any((element) => element["barcode"] == barcode)) {
      setState(() {
        searchedProductsList =
            vanProductsController.vanProductsList.where((element) {
          return element["barcode"]
              .toString()
              .toLowerCase()
              .contains(barcode.toLowerCase());
        }).toList();
      });
    } else {
      searchedProductsList = vanProductsController.vanProductsList;
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
            searchedProductsList =
                vanProductsController.vanProductsList.where((element) {
              return element["product_name"]
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase());
            }).toList();
          });
          if (value.isEmpty) {
            setState(() {
              searchedProductsList = vanProductsController.vanProductsList;
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
                      searchedProductsList =
                          vanProductsController.vanProductsList;
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

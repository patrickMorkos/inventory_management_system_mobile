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
import 'package:inventory_management_system_mobile/view/widgets/empty_screen_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';

class VanProductsScreen extends StatefulWidget {
  const VanProductsScreen({super.key});

  @override
  State<VanProductsScreen> createState() => _VanProductsScreenState();
}

class _VanProductsScreenState extends State<VanProductsScreen> {
  //******************************************************************VARIABLES
  bool isFromCreateOrderScreen = false;

  TextEditingController boxQuantityController = TextEditingController();
  TextEditingController itemQuantityController = TextEditingController();

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

  //This variable is the box quantity of the product
  int boxQuantity = 1;

  //This variable is the order controller
  final OrderController orderController = Get.put(OrderController());

  //This variable is the van products controller
  final VanProductsController vanProductsController =
      Get.put(VanProductsController());

  int selectedBoxQuantity = 0;
  int selectedItemsQuantity = 0;

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
          if (boxQuantity > product["box_quantity"] || boxQuantity == 0) {
            Get.snackbar(
              "Error",
              "Cannot add more than quantity",
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
              duration: Duration(seconds: 2),
            );
          } else {
            orderController.addProductToOrder(product["Product"], boxQuantity);
            vanProductsController.deductBoxQuantity(
              product["Product"]["id"],
              boxQuantity,
            );
            Navigator.of(context).pop();
          }
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

  //This function renders the product box quantity
  Widget renderBoxQuantityPickUp(sh, product) {
    return Container(
      padding: EdgeInsets.only(
        top: sh / 50,
      ),
      child: InputQty(
        decoration: QtyDecorationProps(
          btnColor: kMainColor,
          fillColor: Colors.white,
        ),
        onQtyChanged: (value) {
          if (value is String && value.isNotEmpty) {
            final parsedValue = double.tryParse(value);
            if (parsedValue != null) {
              setState(() {
                boxQuantity = parsedValue.toInt();
              });
            }
          } else if (value is double || value is int) {
            setState(() {
              boxQuantity = value.toInt();
            });
          }
        },
      ),
    );
  }

  Widget buildProductDetailRow(String title, String value, double sw) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title:",
              style: TextStyle(
                  fontSize: getResponsiveSize(30),
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(value,
              style: TextStyle(
                  fontSize: getResponsiveSize(30), color: Colors.white)),
        ],
      ),
    );
  }

  void addToCart(product) {
    // print(
    //     "Final Box Quantity: $selectedBoxQuantity, Final Item Quantity: $selectedItemsQuantity");

    bool isBoxSelected = selectedBoxQuantity > 0;
    bool isItemSelected = selectedItemsQuantity > 0;

    if (!isBoxSelected && !isItemSelected) {
      return;
    }

    if (isBoxSelected) {
      orderController.addProductToOrder(
          product["Product"], selectedBoxQuantity);
      vanProductsController.deductBoxQuantity(
          product["Product"]["id"], selectedBoxQuantity);
    }

    if (isItemSelected) {
      if (selectedItemsQuantity < 0) {
        // print("ERROR: Trying to add a negative quantity of items!");
        return;
      }
      orderController.addProductToOrderWithItems(
        product["Product"],
        selectedBoxQuantity, // Pass Box Quantity
        selectedItemsQuantity, // Pass Items Quantity
      );

      vanProductsController.deductItemQuantity(
          product["Product"]["id"], selectedItemsQuantity);
    }

    String successMessage = "";
    if (isBoxSelected && isItemSelected) {
      successMessage = "Box and Item quantities added";
    } else if (isBoxSelected) {
      successMessage = "Box quantity added";
    } else {
      successMessage = "Item quantity added";
    }

    Future.delayed(Duration(milliseconds: 200), () {
      Get.snackbar(
        "Success",
        successMessage,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    });

    // Reset values after adding to cart
    setState(() {
      selectedBoxQuantity = 0;
      selectedItemsQuantity = 0;
    });
  }

  void openProductDetailsDialog(context, sw, sh, product, clientInfo) {
    boxQuantityController.text = selectedBoxQuantity.toString();
    itemQuantityController.text = selectedItemsQuantity.toString();

    String? boxQuantityError;
    String? itemQuantityError;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kMainColor,
          insetPadding: EdgeInsets.zero,
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white),
          ),
          content: SizedBox(
            width: getResponsiveSize(600),
            height: getResponsiveSize(1600),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Product Details",
                    style: TextStyle(
                      fontSize: getResponsiveSize(50),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
              
                  // Product Image
                  Container(
                    width: getResponsiveSize(150),
                    height: getResponsiveSize(150),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        product["Product"]["image_url"] ?? "",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image,
                              color: Colors.grey, size: 40);
                        },
                      ),
                    ),
                  ),
              
                  SizedBox(height: getResponsiveSize(20)),
              
                  // Product Info
                  buildProductDetailRow(
                      "Name", product["Product"]["name"] ?? "", sw),
                  buildProductDetailRow("Brand",
                      product["Product"]["Brand"]["brand_name"] ?? "", sw),
                  buildProductDetailRow("Category",
                      product["Product"]["Category"]["category_name"] ?? "", sw),
                  buildProductDetailRow(
                      "Available QTY", "${product["box_quantity"] ?? 0}", sw),
                  buildProductDetailRow(
                      "Box Price",
                      "\$${product["Product"]["ProductPrice"]["box_price"] ?? 0.0}",
                      sw),
                  buildProductDetailRow(
                      "Items Quantity", "${product["items_quantity"] ?? 0}", sw),
                  buildProductDetailRow(
                      "Item Price",
                      "\$${product["Product"]["ProductPrice"]["item_price"] ?? 0.0}",
                      sw),
                  buildProductDetailRow(
                      "Items Per Box",
                      "${product["Product"]["number_of_items_per_box"] ?? 0.0}",
                      sw),
              
                  SizedBox(height: getResponsiveSize(20)),
              
                  // Box Quantity Selector
                  Text("Select Box Quantity",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: getResponsiveSize(30),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Minus button
                      IconButton(
                        icon: Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: getResponsiveSize(50),
                        ),
                        onPressed: () {
                          if (selectedBoxQuantity > 0) {
                            setState(() {
                              selectedBoxQuantity--;
                              boxQuantityController.text =
                                  selectedBoxQuantity.toString();
                            });
                          }
                        },
                      ),
              
                      // Quantity Input
                      SizedBox(
                        width: getResponsiveSize(
                          300,
                        ), // Increased width for 6-10 digit space
                        child: TextField(
                          controller: boxQuantityController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*$')), // Allow only numbers & .
                          ],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            errorText: boxQuantityError,
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedBoxQuantity =
                                  double.tryParse(value)?.toInt() ?? 0;
                            });
                          },
                        ),
                      ),
              
                      // Plus button
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: getResponsiveSize(50),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedBoxQuantity++;
                            boxQuantityController.text =
                                selectedBoxQuantity.toString();
                          });
                        },
                      ),
                    ],
                  ),
              
                  const SizedBox(height: 10),
              
                  // Item Quantity Selector
                  Text(
                    "Select Items Quantity",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: getResponsiveSize(30),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Minus button
                      IconButton(
                        icon: Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: getResponsiveSize(50),
                        ),
                        onPressed: () {
                          if (selectedItemsQuantity > 0) {
                            setState(() {
                              selectedItemsQuantity--;
                              itemQuantityController.text =
                                  selectedItemsQuantity.toString();
                            });
                          }
                        },
                      ),
              
                      // Quantity Input
                      SizedBox(
                        width: getResponsiveSize(
                          300,
                        ), // Increased width for 6-10 digit space
                        child: TextField(
                          controller: itemQuantityController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*$')), // Allow only numbers & .
                          ],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            errorText: itemQuantityError,
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedItemsQuantity =
                                  double.tryParse(value)?.toInt() ?? 0;
                            });
                          },
                        ),
                      ),
              
                      // Plus button
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: getResponsiveSize(50),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedItemsQuantity++;
                            itemQuantityController.text =
                                selectedItemsQuantity.toString();
                          });
                        },
                      ),
                    ],
                  ),
              
                  const SizedBox(height: 10),
              
                  // Add to Cart Button
                  ElevatedButton(
                    onPressed: () {
                      // Validation: check if quantities exceed the available quantities
                      if (selectedBoxQuantity > product["box_quantity"]) {
                        Get.snackbar(
                          "Error",
                          "Cannot exceed available box quantity.",
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }
              
                      if (selectedItemsQuantity > product["items_quantity"]) {
                        Get.snackbar(
                          "Error",
                          "Cannot exceed available item quantity.",
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }
              
                      // If valid, add to cart
                      if (selectedBoxQuantity > 0 || selectedItemsQuantity > 0) {
                        addToCart(product);
                        Navigator.of(context).pop();
                      } else {
                        Get.snackbar(
                          "Error",
                          "Please select at least one quantity",
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(
                      "Add to Cart",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: getResponsiveSize(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //This function call the get van products API
  Future<void> getVanProducts() async {
    int? clientId;
    if (clientController.clientInfo["id"] != -1) {
      clientId = clientController.clientInfo["id"];
    }
    await getRequest(
      path:
          "/api/van-products/get-all-van-products/${loggedInUserController.loggedInUser.value.id}?client_id=$clientId",
      requireToken: true,
    ).then((value) {
      vanProductsController.setVanProductsInfo(value);
      setState(() {
        searchedProductsList = vanProductsController.vanProductsList;
      });
    });
    if (Get.arguments != null) {
      final arguments = Get.arguments as Map<String, dynamic>;
      categoryId = arguments["category_id"] ?? -1;
      if (categoryId != -1) filterProductsList(categoryId);
    }
  }

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      final arguments = Get.arguments as Map<String, dynamic>;
      categoryId = arguments["category_id"] ?? -1;
      isFromCreateOrderScreen = arguments["isFromCreateOrderScreen"] ?? false;
      if (categoryId != -1) filterProductsList(categoryId);
    }
    getVanProducts();
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
          padding: const EdgeInsets.all(5),
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
    final usdLbpRate = loggedInUserController.loggedInUser.value.usdLbpRate;

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
        final usdFormatter = NumberFormat("#,##0.00", "en_US");
        final lbpFormatter = NumberFormat("#,###", "en_US");
        // Extract values with fallback to 0
        int boxQuantity = element["box_quantity"] ?? 0;
        int itemsQuantity = element["items_quantity"] ?? 0;
        dynamic boxPrice =
            element["Product"]["ProductPrice"]?["box_price"] ?? 0.0;
        dynamic itemPrice =
            element["Product"]["ProductPrice"]?["item_price"] ?? 0.0;

        String formattedBoxPriceUsd = usdFormatter.format(boxPrice);
        String formattedBoxPriceLbp =
            lbpFormatter.format(boxPrice * usdLbpRate);
        String formattedItemPriceUsd = usdFormatter.format(itemPrice);
        String formattedItemPriceLbp =
            lbpFormatter.format(itemPrice * usdLbpRate);

        tmp.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: GestureDetector(
              onTap: () {
                if (isFromCreateOrderScreen) {
                  openProductDetailsDialog(
                    context,
                    sw,
                    sh,
                    element,
                    clientController.clientInfo,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey
                          .withAlpha((0.2 * 255).toInt()), // ✅ Correct method
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Product Image
                    Container(
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
                    SizedBox(width: 12),

                    // Product Name & Brand
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            element["Product"]["name"] ?? "",
                            style: TextStyle(
                                fontSize: getResponsiveSize(30),
                                fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Brand: ${element["Product"]["Brand"]["brand_name"] ?? ""}",
                            style: TextStyle(
                                fontSize: getResponsiveSize(30), color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                    // Product Details in Structured Order
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDetailRow("Available QTY:", "$boxQuantity", sw),
                        buildDetailRow(
                            "Box Price:", "\$ $formattedBoxPriceUsd", sw),
                        buildDetailRow("Box Price:",
                            "LBP $formattedBoxPriceLbp", sw),
                        buildDetailRow("Items Quantity:", "$itemsQuantity", sw),
                        buildDetailRow("Item Price:",
                            "\$ $formattedItemPriceUsd", sw),
                        buildDetailRow("Item Price:",
                            "LBP $formattedItemPriceLbp", sw),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    return tmp;
  }

  // Function to build a properly aligned detail row with responsive fonts
  Widget buildDetailRow(String title, String value, double sw) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: getResponsiveSize(30), // Ensure minimum and max size
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: getResponsiveSize(30),
              color: Colors.black,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
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
    if (searchedProductsList
        .any((element) => element["Product"]["barcod"] == barcode)) {
      setState(() {
        searchedProductsList =
            vanProductsController.vanProductsList.where((element) {
          return element["Product"]["barcod"]
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
      ).onTap(() => {
            // print("Back"),
            // print("orderInfo=======>" + orderController.orderInfo.toString()),
            Get.toNamed("/dashboard"),
          }),
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
              return element["Product"]["name"]
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

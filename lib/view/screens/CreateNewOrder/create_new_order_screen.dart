import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management_system_mobile/core/controllers/client_controller.dart';
import 'package:inventory_management_system_mobile/core/controllers/order_controller.dart';
import 'package:inventory_management_system_mobile/core/controllers/van_products_controller.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:inventory_management_system_mobile/data/api_service.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:inventory_management_system_mobile/view/widgets/empty_screen_widget.dart';

class CreateNewOrderScreen extends StatefulWidget {
  const CreateNewOrderScreen({super.key});

  @override
  State<CreateNewOrderScreen> createState() => _CreateNewOrderScreenState();
}

class _CreateNewOrderScreenState extends State<CreateNewOrderScreen> {
  //******************************************************************VARIABLES

  //This variable is the total price of the order
  double totalOrderPrice = 0.0;

  //This variable is the order controller
  final OrderController orderController = Get.put(OrderController());

  //This variable is the van products controller
  final VanProductsController vanProductsController =
      Get.put(VanProductsController());

  //This variable is the client controller
  final ClientController clientController = Get.put(ClientController());

  //******************************************************************FUNCTIONS

  double applyTaxIfNeeded(double price, bool isTaxable) {
    return isTaxable ? price * 1.11 : price;
  }

  @override
  void initState() {
    super.initState();

    final userTypeId = loggedInUserController.loggedInUser.value.userTypeId;

    // Ensure "Presale" is selected by default if userTypeId == 3
    if (userTypeId == 3 && orderController.orderInfo["saleType"] != "Presale") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        orderController.orderInfo["saleType"] = "Presale";
        orderController.update();
      });
    }

    updateTotalPrice();
  }

  //This function updates the total order price based on the products in the order
  void updateTotalPrice() {
    setState(() {
      totalOrderPrice = 0.0;

      // Safely calculate the total price for products
      if (orderController.orderInfo["products"] != null) {
        totalOrderPrice +=
            orderController.orderInfo["products"].fold(0.0, (sum, product) {
          bool isTaxable = product['product']['is_taxable'] ?? false;

          double boxPrice = applyTaxIfNeeded(
              product['product']['ProductPrice']['box_price']?.toDouble() ??
                  0.0,
              isTaxable);

          double itemPrice = applyTaxIfNeeded(
              product['product']['ProductPrice']['item_price']?.toDouble() ??
                  0.0,
              isTaxable);

          double boxTotal = (product['box_quantity'] ?? 0) * boxPrice;
          double itemTotal = (product['items_quantity'] ?? 0) * itemPrice;

          return sum + boxTotal + itemTotal;
        });
      }

      // Safely calculate the total price for sale products
      if (orderController.orderInfo["saleProducts"] != null) {
        totalOrderPrice +=
            orderController.orderInfo["saleProducts"].fold(0.0, (sum, product) {
          bool isTaxable = product['product']['is_taxable'] ?? false;

          double boxPrice = applyTaxIfNeeded(
              product['box_price']?.toDouble() ?? 0.0, isTaxable);

          double itemPrice = applyTaxIfNeeded(
              product['item_price']?.toDouble() ?? 0.0, isTaxable);

          double boxTotal = (product['box_quantity'] ?? 0) * boxPrice;
          double itemTotal = (product['items_quantity'] ?? 0) * itemPrice;

          return sum + boxTotal + itemTotal;
        });
      }
    });
  }

  //This function calls to add more products to the order
  void addMoreProducts() {
    if (orderController.orderInfo["saleType"] == "Cash Van") {
      Get.toNamed("/van-products", arguments: {
        "isFromCreateOrderScreen": true,
      })?.then((_) {
        // Step 1: Refresh order data when user comes back
        updateTotalPrice();
        setState(() {}); // Step 2: Force UI to rebuild
      });
    } else {
      Get.toNamed("/all-products", arguments: {
        "isFromCreateOrderScreen": true,
      })?.then((_) {
        // Step 1: Refresh order data when user comes back
        updateTotalPrice();
        setState(() {}); // Step 2: Force UI to rebuild
      });
    }
  }

  // This function renders the sale products list
  Widget renderSaleProductsList(sw) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            "Products from Previous Sale",
            style: GoogleFonts.poppins(
              fontSize: getResponsiveSize(30),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...getSaleProductsCards(sw),
      ],
    );
  }

  // This function returns the sale products cards list
  List<Widget> getSaleProductsCards(sw) {
    List<Widget> tmp = [];
    if (orderController.orderInfo["saleProducts"] == null ||
        orderController.orderInfo["saleProducts"].isEmpty) {
      tmp.add(
        Center(
          child: Text(
            "No products from previous sales available.",
            style: TextStyle(fontSize: getResponsiveSize(30)),
          ),
        ),
      );
      return tmp;
    }

    for (var product in orderController.orderInfo["saleProducts"]) {
      // Extract values safely
      int boxQuantity = product['box_quantity'] ?? 0;
      bool isTaxable = product['product']['is_taxable'] ?? false;

      double boxPrice =
          applyTaxIfNeeded(product['box_price']?.toDouble() ?? 0.0, isTaxable);

      double itemPrice =
          applyTaxIfNeeded(product['item_price']?.toDouble() ?? 0.0, isTaxable);

      int itemQuantity = product['items_quantity'] ?? 0;

      double totalBoxPrice = boxQuantity * boxPrice;
      double totalItemPrice = itemQuantity * itemPrice;
      double totalPrice = totalBoxPrice + totalItemPrice;

      // Generate subtitle dynamically
      List<String> subtitleLines = [];
      if (boxQuantity > 0) {
        subtitleLines.add(
            "Box Quantity: $boxQuantity x \$${boxPrice.toStringAsFixed(2)}");
        subtitleLines.add("= \$${totalBoxPrice.toStringAsFixed(2)}");
      }
      if (itemQuantity > 0) {
        subtitleLines.add(
            "Item Quantity: $itemQuantity x \$${itemPrice.toStringAsFixed(2)}");
        subtitleLines.add("= \$${totalItemPrice.toStringAsFixed(2)}");
      }
      subtitleLines.add("Total: \$${totalPrice.toStringAsFixed(2)}");

      tmp.add(
        ListTile(
          contentPadding: EdgeInsets.only(right: -200),
          leading: Image.network(
            product["product"]["image_url"] ?? "",
            width: getResponsiveSize(90),
            height: getResponsiveSize(90),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.broken_image);
            },
          ),
          title: Text(
            product["product"]["name"] ?? "Unnamed Product",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: getResponsiveSize(30),
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitleLines.join("\n"),
            style: TextStyle(color: Colors.grey, fontSize: sw * 0.03),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Increase Box Quantity
              SizedBox(
                width: 30,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      product["box_quantity"] += 1;
                      updateTotalPrice();
                    });
                  },
                  icon: Icon(Icons.add, size: getResponsiveSize(35)),
                ),
              ),
              // Decrease Box Quantity
              SizedBox(
                width: 30,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      if (product["box_quantity"] > 1) {
                        product["box_quantity"] -= 1;
                        updateTotalPrice();
                      }
                    });
                  },
                  icon: Icon(Icons.remove, size: getResponsiveSize(35)),
                ),
              ),
              // Increase Item Quantity
              SizedBox(
                width: 30,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      product["items_quantity"] += 1;
                      updateTotalPrice();
                    });
                  },
                  icon: Icon(Icons.add, size: getResponsiveSize(35)),
                ),
              ),
              // Decrease Item Quantity
              SizedBox(
                width: 30,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      if (product["items_quantity"] > 1) {
                        product["items_quantity"] -= 1;
                        updateTotalPrice();
                      }
                    });
                  },
                  icon: Icon(Icons.remove, size: getResponsiveSize(35)),
                ),
              ),
              // Delete Product
              SizedBox(
                width: 30,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      orderController.orderInfo["saleProducts"].remove(product);
                      updateTotalPrice();
                    });
                  },
                  icon: Icon(Icons.delete, size: getResponsiveSize(35)),
                ),
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
    return tmp;
  }

  //This function renders the order products list
  Widget renderOrderProductsList(sw) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header for current products
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  "Products from Current Sale",
                  style: GoogleFonts.poppins(
                    fontSize: getResponsiveSize(30),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (orderController.orderInfo["products"] == null ||
                  orderController.orderInfo["products"].isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "No products added to the current order yet.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: getResponsiveSize(30),
                    ),
                  ),
                )
              else
                ...getOrderProductsCards(sw),
              const Divider(
                thickness: 2,
                color: Colors.grey,
              ),
              // Sale products section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  "Products from Previous Sale",
                  style: GoogleFonts.poppins(
                    fontSize: getResponsiveSize(30),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (orderController.orderInfo["saleProducts"] == null ||
                  orderController.orderInfo["saleProducts"].isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "No products from previous sales available.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: getResponsiveSize(30),
                    ),
                  ),
                )
              else
                ...getSaleProductsCards(sw),
            ],
          ),
        ),
      ),
    );
  }

  //This function returns the order product cards list
  List<Widget> getOrderProductsCards(sw) {
    List<Widget> tmp = [];
    if (orderController.orderInfo["products"] == null ||
        orderController.orderInfo["products"].isEmpty) {
      tmp.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 60),
            child: EmptyScreenWidget(),
          ),
        ),
      );
    } else {
      for (var product in orderController.orderInfo["products"]) {
        // Extract values safely
        int boxQuantity = product['box_quantity'] ?? 0;
        bool isTaxable = product['product']['is_taxable'] ?? false;

        double boxPrice = applyTaxIfNeeded(
            product['product']['ProductPrice']['box_price']?.toDouble() ?? 0.0,
            isTaxable);

        double itemPrice = applyTaxIfNeeded(
            product['product']['ProductPrice']['item_price']?.toDouble() ?? 0.0,
            isTaxable);

        int itemQuantity = product['items_quantity'] ?? 0;

        double totalBoxPrice = boxQuantity * boxPrice;
        double totalItemPrice = itemQuantity * itemPrice;
        double totalPrice = totalBoxPrice + totalItemPrice;

        // Generate subtitle dynamically
        List<String> subtitleLines = [];
        if (boxQuantity > 0) {
          subtitleLines.add(
              "Box Quantity: $boxQuantity x \$${boxPrice.toStringAsFixed(2)}");
          subtitleLines.add("= \$${totalBoxPrice.toStringAsFixed(2)}");
        }
        if (itemQuantity > 0) {
          subtitleLines.add(
              "Item Quantity: $itemQuantity x \$${itemPrice.toStringAsFixed(2)}");
          subtitleLines.add("= \$${totalItemPrice.toStringAsFixed(2)}");
        }
        subtitleLines.add("Total: \$${totalPrice.toStringAsFixed(2)}");

        tmp.add(
          ListTile(
            contentPadding: EdgeInsets.only(right: -200),
            leading: Image.network(
              product["product"]["image_url"] ?? "",
              width: getResponsiveSize(90),
              height: getResponsiveSize(90),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image);
              },
            ),
            title: Text(
              product["product"]["name"] ?? "Unnamed Product",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                  fontSize: getResponsiveSize(30), fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              subtitleLines.join("\n"),
              style: TextStyle(color: Colors.grey, fontSize: sw * 0.03),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Increase Box Quantity
                SizedBox(
                  width: 30,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        orderController
                            .increaseProductBoxQuantity(product['product']);
                        vanProductsController.deductBoxQuantity(
                            product['product']["id"], 1);
                        updateTotalPrice();
                      });
                    },
                    icon: Icon(Icons.add, size: getResponsiveSize(35)),
                  ),
                ),
                // Decrease Box Quantity
                SizedBox(
                  width: 30,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        if (boxQuantity > 1) {
                          orderController
                              .decreaseProductBoxQuantity(product['product']);
                          vanProductsController.addBoxQuantity(
                              product['product']["id"], 1);
                          updateTotalPrice();
                        }
                      });
                    },
                    icon: Icon(Icons.remove, size: getResponsiveSize(35)),
                  ),
                ),
                // Increase Item Quantity
                SizedBox(
                  width: 30,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        orderController
                            .increaseProductItemQuantity(product['product']);
                        vanProductsController.deductItemQuantity(
                            product['product']["id"], 1);
                        updateTotalPrice();
                      });
                    },
                    icon: Icon(Icons.add, size: getResponsiveSize(35)),
                  ),
                ),
                // Decrease Item Quantity
                SizedBox(
                  width: 30,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        if (itemQuantity > 1) {
                          orderController
                              .decreaseProductItemQuantity(product['product']);
                          vanProductsController.addItemQuantity(
                              product['product']["id"], 1);
                          updateTotalPrice();
                        }
                      });
                    },
                    icon: Icon(Icons.remove, size: getResponsiveSize(35)),
                  ),
                ),
                // Delete Product
                SizedBox(
                  width: 30,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        orderController
                            .removeProductFromOrder(product['product']);
                        vanProductsController.addBoxQuantity(
                            product['product']["id"], product['box_quantity']);
                        vanProductsController.addItemQuantity(
                            product['product']["id"],
                            product['items_quantity']);
                        updateTotalPrice();
                      });
                    },
                    icon: Icon(Icons.delete, size: getResponsiveSize(35)),
                  ),
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
        "Order Cart",
        style: GoogleFonts.poppins(
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  //This function renders the total order price
  Widget renderTotalOrderPrice() {
    final usdLbpRate = loggedInUserController.loggedInUser.value.usdLbpRate;

    final usdFormatter = NumberFormat("#,##0.00", "en_US");
    final lbpFormatter = NumberFormat("#,###", "en_US");
    String formattedPriceUsd = usdFormatter.format(totalOrderPrice);
    String formattedPriceLbp =
        lbpFormatter.format(totalOrderPrice * usdLbpRate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Total Price:",
            style: GoogleFonts.poppins(fontSize: getResponsiveSize(30)),
          ),
          Text(
            "\$$formattedPriceUsd / LBP $formattedPriceLbp",
            style: GoogleFonts.poppins(
                fontSize: getResponsiveSize(30), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Render buttons row
  Widget renderButtonsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: addMoreProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                textStyle: GoogleFonts.poppins(
                  fontSize: getResponsiveSize(30),
                  color: Colors.white,
                ),
              ),
              child: Text("Add More Products",
                  style: TextStyle(fontSize: getResponsiveSize(30))),
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Add functionality for creating an order here
                orderController.createOrder(
                  totalOrderPrice,
                  orderController.orderInfo["saleType"] == "Cash Van"
                      ? false
                      : true,
                  orderController.orderInfo["saleType"],
                  clientController.clientInfo['id'],
                  loggedInUserController.loggedInUser.value.id,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                textStyle: GoogleFonts.poppins(
                  fontSize: getResponsiveSize(30),
                  color: Colors.white,
                ),
              ),
              child: Text("Submit",
                  style: TextStyle(fontSize: getResponsiveSize(30))),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSaleTypeChange(String newSaleType) {
    if (orderController.orderInfo["saleType"] != newSaleType) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Change Sale Type?",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: Text(
              "Switching the sale type will remove all products from the cart. Do you want to continue?",
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cancel
                },
                child: Text("Cancel",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () {
                  orderController.clearOrderController();
                  orderController.orderInfo["saleType"] = newSaleType;
                  orderController.update();
                  setState(() {});
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("Continue",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, color: Colors.red)),
              ),
            ],
          );
        },
      );
    }
  }

  // Function to render payment and sale type radio buttons
  Widget renderPaymentAndSaleTypeOptions() {
    final userTypeId = loggedInUserController.loggedInUser.value.userTypeId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sale type radio buttons
          Text(
            "Sale Type:",
            style: GoogleFonts.poppins(
                fontSize: getResponsiveSize(30), fontWeight: FontWeight.bold),
          ),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Radio<String>(
                        value: "Cash Van",
                        groupValue: orderController.orderInfo["saleType"],
                        onChanged: userTypeId == 3
                            ? null
                            : (value) {
                                _confirmSaleTypeChange(value!);
                              },
                      ),
                      Text(
                        "Cash Van",
                        style: GoogleFonts.poppins(
                          fontSize: getResponsiveSize(30),
                          color: userTypeId == 3 ? Colors.grey : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Radio<String>(
                        value: "Presale",
                        groupValue: orderController.orderInfo["saleType"],
                        onChanged: (value) {
                          _confirmSaleTypeChange(value!);
                        },
                      ),
                      Text(
                        "Presale",
                        style: GoogleFonts.poppins(
                          fontSize: getResponsiveSize(30),
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
              renderOrderProductsList(sw),
              renderTotalOrderPrice(),
              renderPaymentAndSaleTypeOptions(),
              renderButtonsRow(),
            ],
          ),
        ),
      ),
    );
  }
}

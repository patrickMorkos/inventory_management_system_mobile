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
          return sum +
              (product['box_quantity'] *
                  product['product']['ProductPrice']['box_price']);
        });
      }

      // Safely calculate the total price for sale products
      if (orderController.orderInfo["saleProducts"] != null) {
        totalOrderPrice +=
            orderController.orderInfo["saleProducts"].fold(0.0, (sum, product) {
          return sum + (product['box_quantity'] * product['box_price']);
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
  Widget renderSaleProductsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            "Products from Previous Sale",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...getSaleProductsCards(),
      ],
    );
  }

  // This function returns the sale products cards list
  List<Widget> getSaleProductsCards() {
    List<Widget> tmp = [];
    if (orderController.orderInfo["saleProducts"] == null ||
        orderController.orderInfo["saleProducts"].isEmpty) {
      tmp.add(
        const Center(
          child: Text("No products from previous sales available."),
        ),
      );
      return tmp;
    }

    for (var product in orderController.orderInfo["saleProducts"]) {
      tmp.add(
        ListTile(
          contentPadding: EdgeInsets.only(right: -200),
          leading: Image.network(
            product["product"]["image_url"] ?? "",
            width: 50,
            height: 50,
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
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            "Box Quantity: ${product['box_quantity']} x \$${product['box_price']} \n= \$${(product['box_quantity'] * product['box_price']).toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 30,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      // Increase product box quantity
                      product["box_quantity"] += 1;
                      updateTotalPrice();
                    });
                  },
                  icon: const Icon(Icons.add, size: 15),
                ),
              ),
              SizedBox(
                width: 30,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      // Decrease product box quantity
                      if (product["box_quantity"] > 1) {
                        product["box_quantity"] -= 1;
                        updateTotalPrice();
                      }
                    });
                  },
                  icon: const Icon(Icons.remove, size: 15),
                ),
              ),
              SizedBox(
                width: 30,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      // Remove product from the sale products list
                      orderController.orderInfo["saleProducts"].remove(product);
                      updateTotalPrice();
                    });
                  },
                  icon: const Icon(Icons.delete, size: 15),
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
  Widget renderOrderProductsList() {
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (orderController.orderInfo["products"] == null ||
                  orderController.orderInfo["products"].isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "No products added to the current order yet.",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...getOrderProductsCards(),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (orderController.orderInfo["saleProducts"] == null ||
                  orderController.orderInfo["saleProducts"].isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "No products from previous sales available.",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...getSaleProductsCards(),
            ],
          ),
        ),
      ),
    );
  }

  //This function returns the order product cards list
  List<Widget> getOrderProductsCards() {
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
        tmp.add(
          ListTile(
            contentPadding: EdgeInsets.only(right: -200),
            leading: Image.network(
              product["product"]["image_url"] ?? "",
              width: 50,
              height: 50,
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
                  fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              "Box Quantity: ${product['box_quantity']} x \$${product['product']['ProductPrice']['box_price']} \n= \$${(product['box_quantity'] * product['product']['ProductPrice']['box_price']).toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                    icon: const Icon(Icons.add, size: 15),
                  ),
                ),
                SizedBox(
                  width: 30,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        if (product['box_quantity'] > 1) {
                          orderController
                              .decreaseProductBoxQuantity(product['product']);
                          vanProductsController.addBoxQuantity(
                              product['product']["id"], 1);
                          updateTotalPrice();
                        }
                      });
                    },
                    icon: const Icon(Icons.remove, size: 15),
                  ),
                ),
                SizedBox(
                  width: 30,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        orderController
                            .removeProductFromOrder(product['product']);
                        vanProductsController.addBoxQuantity(
                            product['product']["id"], product['box_quantity']);
                        updateTotalPrice();
                      });
                    },
                    icon: const Icon(Icons.delete, size: 15),
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
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          Text(
            "\$$formattedPriceUsd / LBP $formattedPriceLbp",
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
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
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              child: const Text("Add More Products"),
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
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              child: const Text("Submit"),
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
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
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
                          fontSize: 14,
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
                          fontSize: 14,
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
              renderOrderProductsList(),
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

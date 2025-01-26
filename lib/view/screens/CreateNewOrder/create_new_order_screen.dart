import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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

  //This variable is the list of products added to the order
  // List<dynamic> orderProductsList = [];

  //This variable is the total price of the order
  double totalOrderPrice = 0.0;

  //This variable is the order controller
  final OrderController orderController = Get.put(OrderController());

  //This variable is the van products controller
  final VanProductsController vanProductsController =
      Get.put(VanProductsController());

  // Variables to track checkbox states
  bool isPendingPayment = false;
  String saleType = "Cash Van";

  //This variable is the client controller
  final ClientController clientController = Get.put(ClientController());

  //******************************************************************FUNCTIONS

  @override
  void initState() {
    super.initState();
    updateTotalPrice();
  }

  //This function updates the total order price based on the products in the order
  void updateTotalPrice() {
    setState(() {
      totalOrderPrice =
          orderController.orderInfo["products"].fold(0.0, (sum, product) {
        return sum +
            (product['quantity'] * product['product']['ProductPrice']['price']);
      });
    });
  }

  //This function calls to add more products to the order
  void addMoreProducts() {
    Get.toNamed("/van-products");
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
          title: Text(
            product["product"]["name"] ?? "Unnamed Product",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            "Quantity: ${product['quantity']} x \$${product['product_price']} = \$${(product['quantity'] * product['product_price']).toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.grey),
          ),
          leading: Image.network(
            product["product"]["image_url"] ?? "",
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.broken_image);
            },
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
              // Check for null or empty products list
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
              "Quantity: ${product['quantity']} x \$${product['product']['ProductPrice']['price']} = \$${(product['quantity'] * product['product']['ProductPrice']['price']).toStringAsFixed(2)}",
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      orderController
                          .increaseProductQuantity(product['product']);
                      vanProductsController.deductQuantity(
                          product['product']["id"], 1);
                      updateTotalPrice();
                    });
                  },
                  icon: const Icon(Icons.add, size: 20),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (product['quantity'] > 1) {
                        orderController
                            .decreaseProductQuantity(product['product']);
                        vanProductsController.addQuantity(
                            product['product']["id"], 1);
                        updateTotalPrice();
                      }
                    });
                  },
                  icon: const Icon(Icons.remove, size: 20),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      orderController
                          .removeProductFromOrder(product['product']);
                      vanProductsController.addQuantity(
                          product['product']["id"], product['quantity']);
                      updateTotalPrice();
                    });
                  },
                  icon: const Icon(Icons.delete, size: 20),
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
        "Create New Order",
        style: GoogleFonts.poppins(
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  //This function renders the total order price
  Widget renderTotalOrderPrice() {
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
            "\$${totalOrderPrice.toStringAsFixed(2)}",
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
                  isPendingPayment,
                  saleType,
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
              child: const Text("Create Order"),
            ),
          ),
        ],
      ),
    );
  }

  // Function to render payment and sale type radio buttons
  Widget renderPaymentAndSaleTypeOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment status radio buttons
          Text(
            "Payment Status:",
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Column(
            children: [
              Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: isPendingPayment,
                    onChanged: (value) {
                      setState(() {
                        isPendingPayment = value ?? false;
                      });
                    },
                  ),
                  Text(
                    "Pending Payment",
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  Radio<bool>(
                    value: false,
                    groupValue: isPendingPayment,
                    onChanged: (value) {
                      setState(() {
                        isPendingPayment = value ?? false;
                      });
                    },
                  ),
                  Text(
                    "Immediate Payment",
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          // Sale type radio buttons
          Text(
            "Sale Type:",
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Radio<String>(
                      value: "Cash Van",
                      groupValue: saleType,
                      onChanged: (value) {
                        setState(() {
                          saleType = value!;
                        });
                      },
                    ),
                    Text(
                      "Cash Van",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Radio<String>(
                      value: "Presale",
                      groupValue: saleType,
                      onChanged: (value) {
                        setState(() {
                          saleType = value!;
                        });
                      },
                    ),
                    Text(
                      "Presale",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
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

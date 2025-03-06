import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management_system_mobile/core/controllers/logged_in_user_controller.dart';
import 'package:inventory_management_system_mobile/core/controllers/order_controller.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

class SaleProductsDialog extends StatefulWidget {
  final List<dynamic> products;

  const SaleProductsDialog({
    super.key,
    required this.products,
  });

  @override
  State<SaleProductsDialog> createState() => _SaleProductsDialogState();
}

class _SaleProductsDialogState extends State<SaleProductsDialog> {
  String priceSelection = "Old Prices"; // Default to "Old Prices"

  // Calculate the total price of the sale
  double getTotalSalePrice() {
    return widget.products.fold(0.0, (total, product) {
      return total + (product['quantity'] * product['product_price']);
    });
  }

  final ScrollController _scrollController = ScrollController();

  //This variable is the order controller
  final OrderController orderController = Get.put(OrderController());

  //This variable is for the logged in user data
  final LoggedInUserController loggedInUserController =
      Get.put(LoggedInUserController());

  //******************************************************************FUNCTIONS

  //This function renders the dialog header
  Widget renderHeader() {
    return Text(
      "Sale Products",
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  //This function renders empty sale
  Widget renderEmptySale() {
    return Center(
      child: Text(
        "No products found for this sale.",
        style: GoogleFonts.poppins(
          fontSize: 16,
        ),
      ),
    );
  }

  //This function renders the products list with total price for each product
  Widget renderProductList() {
    final usdLbpRate = loggedInUserController.loggedInUser.value.usdLbpRate;

    return SizedBox(
      height: 200, // Set a fixed height
      child: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController, // Attach controller
          physics: AlwaysScrollableScrollPhysics(), // Ensure scrolling
          itemCount: widget.products.length,
          itemBuilder: (context, index) {
            final product = widget.products[index];
            final productTotalPrice =
                product['quantity'] * product['product_price'];

            final usdFormatter = NumberFormat("#,##0.00", "en_US");
            final lbpFormatter = NumberFormat("#,###", "en_US");
            String productTotalPriceUsd =
                usdFormatter.format(productTotalPrice);
            String productTotalPriceLbp =
                lbpFormatter.format(productTotalPrice * usdLbpRate);

            return ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[200],
                child: Image.network(
                  product['Product']['image_url'] ?? '',
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
              title: Text(
                product['Product']['name'] ?? "Unknown Product",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                "Quantity: ${product['quantity']}\nPrice: \$${product['product_price']}\nTotal: \$$productTotalPriceUsd / LBP $productTotalPriceLbp",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  //This function renders the price selection radio buttons
  Widget renderPriceSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Price Selection:",
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Column(
            children: [
              Row(
                children: [
                  Radio<String>(
                    activeColor: Colors.black,
                    value: "Old Prices",
                    groupValue: priceSelection,
                    onChanged: (value) {
                      setState(() {
                        priceSelection = value!;
                      });
                    },
                  ),
                  Text(
                    "Use Old Prices",
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    activeColor: Colors.black,
                    value: "New Prices",
                    groupValue: priceSelection,
                    onChanged: (value) {
                      setState(() {
                        priceSelection = value!;
                      });
                    },
                  ),
                  Text(
                    "Use New Prices",
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  //This function renders buttons aligned horizontally
  Widget renderActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              orderController.addSaleProductsToOrder(
                  widget.products, priceSelection);

              // Show toast message
              Fluttertoast.showToast(
                msg:
                    "Previous sale products successfully added to current order cart",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                timeInSecForIosWeb: 3,
              );

              Navigator.of(context).pop(); // Close dialog
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Replicate Sale",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Close",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  //This function renders the total sale price at the bottom
  Widget renderTotalSalePrice() {
    final usdLbpRate = loggedInUserController.loggedInUser.value.usdLbpRate;

    final usdFormatter = NumberFormat("#,##0.00", "en_US");
    final lbpFormatter = NumberFormat("#,###", "en_US");
    String formattedPriceUsd = usdFormatter.format(getTotalSalePrice());
    String formattedPriceLbp =
        lbpFormatter.format(getTotalSalePrice() * usdLbpRate);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Total Sale Price: \$$formattedPriceUsd \nLBP $formattedPriceLbp",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kMainColor,
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: Colors.white,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            renderHeader(),
            widget.products.isEmpty
                ? renderEmptySale()
                : Expanded(child: renderProductList()), // Ensure scrolling
            renderPriceSelection(),
            renderTotalSalePrice(),
            renderActionButtons(context),
          ],
        ),
      ),
    );
  }
}

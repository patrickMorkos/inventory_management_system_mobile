import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';

class SaleProductsDialog extends StatelessWidget {
  final List<dynamic> products;

  const SaleProductsDialog({
    super.key,
    required this.products,
  });

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

  //This function renders the products list
  Widget renderProductList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                NetworkImage(product['Product']['image_url'] ?? ''),
            radius: 25,
            backgroundColor: Colors.grey[200],
          ),
          title: Text(
            product['Product']['name'] ?? "Unknown Product",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            "Quantity: ${product['quantity']}\nPrice: \$${product['product_price']}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }

  //This function renders close button
  Widget renderCloseButton(context) {
    return ElevatedButton(
      onPressed: () => Navigator.of(context).pop(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        "Close",
        style: GoogleFonts.poppins(color: Colors.white),
      ),
    );
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
        height: MediaQuery.of(context).size.height * 0.5,
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                renderHeader(),
                const SizedBox(height: 16),
                products.isEmpty ? renderEmptySale() : renderProductList(),
                const SizedBox(height: 16),
                renderCloseButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//This function renders the product descrption header
import 'package:flutter/material.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';

Widget renderProductDescriptionHeader(sh) {
  return Center(
    child: Container(
      padding: EdgeInsets.only(
        top: sh / 50,
        bottom: sh / 50,
      ),
      child: const Text(
        'Product Details',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

//This function renders the product image
Widget renderProductImage(sw, sh, product) {
  return SizedBox(
    height: sw / 2,
    width: sw / 2,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.network(
        product["Product"]["image_url"] ?? "",
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
  );
}

//This function renders the product name
Widget renderProductItems(sw, sh, prefix, title) {
  return Container(
    width: sw * 0.7,
    padding: EdgeInsets.only(
      top: sh / 40,
    ),
    child: Text(
      "-$prefix: $title",
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      textAlign: TextAlign.start,
    ),
  );
}

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
        // addProductToCart(context, sw, sh, product, clientInfo);
        print("add product to cart");
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
            width: sw * 0.8,
            height: sh * 0.7,
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
                    product["Product"]["ProductPrice"]["pricea1"] ?? "",
                  ),

                  //Add product to cart
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
        ],
      );
    },
  );
}

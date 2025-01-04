//This function renders the product descrption header
import 'package:flutter/material.dart';

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
  return SizedBox(
    width: sw * 0.7,
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
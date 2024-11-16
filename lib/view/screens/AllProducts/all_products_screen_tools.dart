import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';

void openDialog(context, sw, sh, stock, barcode) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: kMainColor,
        insetPadding: EdgeInsets.zero,
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          Column(
            children: [
              //Alert dialog Header
              Center(
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: sh / 50,
                    top: sh / 50,
                  ),
                  child: const Text(
                    'Product not found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Text('Do you want to add it?'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Get.toNamed('/addProduct', arguments: [
                        stock,
                        barcode,
                      ]);
                    },
                    child: const Text(
                      'Yes',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'No',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      );
    },
  );
}

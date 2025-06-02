import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/controllers/product_controller.dart';
import 'package:inventory_management_system_mobile/data/api_service.dart';

class CreateProductModal extends StatefulWidget {
  const CreateProductModal({super.key});

  @override
  State<CreateProductModal> createState() => _CreateProductModalState();
}

class _CreateProductModalState extends State<CreateProductModal> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController boxQtyController = TextEditingController();
  final TextEditingController itemQtyController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController packController = TextEditingController();

  Uint8List? selectedImageBytes;
  List<Map<String, dynamic>> categories = [];
  Map<String, dynamic>? selectedCategory;
  List<Map<String, dynamic>> brands = [];
  Map<String, dynamic>? selectedBrand;
  bool isTaxable = false;
  File? selectedImageFile;
  String? selectedImageFileName;
  final ProductController productController = Get.find<ProductController>();

  Future<void> fetchCategories() async {
    var response = await getRequest(
      path: "/api/category/get-all-categories",
      requireToken: true,
    );

    if (response is List) {
      setState(() {
        categories = response.map((e) => (e as Map<String, dynamic>)).toList();
      });
    }
  }

  Future<void> fetchBrands() async {
    var response = await getRequest(
      path: "/api/brand/get-all-brands",
      requireToken: true,
    );

    if (response is List) {
      setState(() {
        brands = response.map((e) => (e as Map<String, dynamic>)).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchBrands();
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      selectedImageFileName = result.files.first.name;

      if (kIsWeb && result.files.first.bytes != null) {
        selectedImageBytes = result.files.first.bytes;
        selectedImageFile =
            File.fromRawPath(selectedImageBytes!); // dummy fallback
      } else {
        selectedImageFile = File(result.files.first.path!);
        selectedImageBytes = null;
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Product'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Product Name')),
            TextField(
                controller: barcodeController,
                decoration: InputDecoration(labelText: 'Barcode')),
            SizedBox(height: 10),
            DropdownSearch<Map<String, dynamic>>(
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    labelText: "Search Brand",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              decoratorProps: DropDownDecoratorProps(
                decoration: InputDecoration(
                  labelText: "Select Brand",
                  border: OutlineInputBorder(),
                ),
              ),
              items: (filter, props) => brands,
              itemAsString: (brand) =>
                  brand["brand_name"], // Adjust key if needed
              compareFn: (item1, item2) => item1["id"] == item2["id"],
              onChanged: (value) {
                setState(() {
                  selectedBrand = value;
                });
              },
              selectedItem: selectedBrand,
            ),
            SizedBox(height: 8),
            DropdownSearch<Map<String, dynamic>>(
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    labelText: "Search Category",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              decoratorProps: DropDownDecoratorProps(
                decoration: InputDecoration(
                  labelText: "Select Category",
                  border: OutlineInputBorder(),
                ),
              ),
              items: (filter, props) => categories,
              itemAsString: (category) => category["category_name"],
              compareFn: (item1, item2) => item1["id"] == item2["id"],
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              selectedItem: selectedCategory,
            ),
            TextField(
                controller: boxQtyController,
                decoration: InputDecoration(labelText: 'Box Quantity'),
                keyboardType: TextInputType.number),
            TextField(
                controller: itemQtyController,
                decoration: InputDecoration(labelText: 'Item Quantity'),
                keyboardType: TextInputType.number),
            TextField(
                controller: unitController,
                decoration: InputDecoration(labelText: 'Unit')),
            TextField(
                controller: packController,
                decoration: InputDecoration(labelText: 'Pack'),
                keyboardType: TextInputType.number),
            SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: isTaxable,
                  onChanged: (value) {
                    setState(() {
                      isTaxable = value ?? false;
                    });
                  },
                ),
                const Text('Is Taxable'),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                await pickImage();
              },
              child: Text("Pick Image"),
            ),
            if (kIsWeb && selectedImageBytes != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.memory(selectedImageBytes!, height: 100),
              )
            else if (!kIsWeb && selectedImageFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.file(selectedImageFile!, height: 100),
              )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = nameController.text.trim();
            final barcode = barcodeController.text.trim();
            final unit = unitController.text.trim();
            final pack = int.tryParse(packController.text.trim()) ?? 0;
            final boxQty = int.tryParse(boxQtyController.text.trim()) ?? 0;
            final itemQty = int.tryParse(itemQtyController.text.trim()) ?? 0;

            if (name.isEmpty ||
                selectedCategory == null ||
                selectedBrand == null) {
              Get.snackbar("Error", "Please fill all required fields.",
                  backgroundColor: Colors.red, colorText: Colors.white);
              return;
            }

            final body = {
              "barcod": barcode,
              "name": name,
              "unit": unit,
              "is_taxable": isTaxable,
              "brand_id": selectedBrand!["id"],
              "category_id": selectedCategory!["id"],
              "createdAt": DateTime.now().toIso8601String(),
              "updatedAt": DateTime.now().toIso8601String(),
              "number_of_items_per_box": pack
            };

            final Map<String, dynamic> files = {};

            if (kIsWeb && selectedImageBytes != null) {
              files["image_url"] = selectedImageBytes!;
            } else if (!kIsWeb && selectedImageFile != null) {
              files["image_url"] = selectedImageFile!;
            }

            final res = await postRequestWithFiles(
              path: "/api/product/create-product",
              data: body,
              files: files,
              requireToken: true,
            );

            if (res?['id'] != null) {
              final productId = res['id'];

              final stockRes = await postRequest(
                path: "/api/main-warehouse-stock/add-products",
                body: [
                  {
                    "product_id": productId,
                    "box_quantity": boxQty,
                    "items_quantity": itemQty,
                  }
                ],
                requireToken: true,
              );

              if (stockRes != null) {
                productController.fetchProducts(); // Refresh product list
                Get.back(); // Then close modal
                Get.snackbar("Success", "Product created successfully!",
                    backgroundColor: Colors.green, colorText: Colors.white);
              } else {
                Get.snackbar("Error", "Failed to add product to warehouse.",
                    backgroundColor: Colors.red, colorText: Colors.white);
              }
            } else {
              final error = res?['error'] ?? 'Failed to create product';
              Get.snackbar("Error", error,
                  backgroundColor: Colors.red, colorText: Colors.white);
            }
          },
          child: Text('Create'),
        ),
      ],
    );
  }
}

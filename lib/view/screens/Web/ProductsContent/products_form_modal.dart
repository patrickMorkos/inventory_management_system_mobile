import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/controllers/product_controller.dart';
import 'package:inventory_management_system_mobile/core/models/product_model.dart';
import 'package:inventory_management_system_mobile/data/api_service.dart';

class CreateProductModal extends StatefulWidget {
  final ProductModel? product;
  const CreateProductModal({super.key, this.product});
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

  String? existingImageUrl;

  @override
  void initState() {
    super.initState();

    fetchCategories().then((_) {
      if (widget.product != null) {
        selectedCategory = categories.firstWhereOrNull(
          (cat) => cat['category_name'] == widget.product!.categoryName,
        );
        setState(() {});
      }
    });

    fetchBrands().then((_) {
      if (widget.product != null) {
        selectedBrand = brands.firstWhereOrNull(
          (brand) => brand['brand_name'] == widget.product!.brandName,
        );
        setState(() {});
      }
    });

    if (widget.product != null) {
      nameController.text = widget.product!.name;
      barcodeController.text = widget.product!.barcod ?? '';
      unitController.text = widget.product!.unit ?? '';
      packController.text = widget.product!.pack?.toString() ?? '';
      boxQtyController.text = widget.product!.boxQuantity.toString();
      itemQtyController.text = widget.product!.itemQuantity.toString();
      isTaxable = widget.product!.isTaxable ?? false;
      selectedImageFile = null;
      selectedImageBytes = null;
      existingImageUrl = widget.product!.imageUrl;
    }
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
            else if (existingImageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.network(existingImageUrl!, height: 100),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Note: Please set the product prices using the "Prices" button in the main table after creating the product.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
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
            final Map<String, dynamic> files = {};
            bool shouldUpdateImage = (kIsWeb && selectedImageBytes != null) ||
                (!kIsWeb && selectedImageFile != null);

            if (widget.product != null) {
              bool shouldUpdateProduct = false;
              bool shouldUpdateQuantities = false;

              // Check quantity fields
              final originalBoxQty = widget.product!.boxQuantity;
              final originalItemQty = widget.product!.itemQuantity;

              if (boxQty != originalBoxQty || itemQty != originalItemQty) {
                shouldUpdateQuantities = true;
              }

              // Check all other fields
              if (name != widget.product!.name ||
                  barcode != (widget.product!.barcod ?? '') ||
                  unit != (widget.product!.unit ?? '') ||
                  pack != (widget.product!.pack ?? 0) ||
                  selectedBrand?['brand_name'] != widget.product!.brandName ||
                  selectedCategory?['category_name'] !=
                      widget.product!.categoryName ||
                  isTaxable != (widget.product!.isTaxable ?? false)) {
                // because you defaulted it
                shouldUpdateProduct = true;
              }

              if (kIsWeb && selectedImageBytes != null) {
                files["image_url"] = selectedImageBytes!;
              } else if (!kIsWeb && selectedImageFile != null) {
                files["image_url"] = selectedImageFile!;
              }

              if (shouldUpdateProduct || shouldUpdateImage) {
                final Map<String, dynamic> body = {};

                if (name != widget.product!.name) {
                  body["name"] = name;
                }

                if (barcode != (widget.product!.barcod ?? '')) {
                  body["barcod"] = barcode;
                }

                if (unit != (widget.product!.unit ?? '')) {
                  body["unit"] = unit;
                }

                if (pack != (widget.product!.pack ?? 0)) {
                  body["number_of_items_per_box"] = pack;
                }

                if (selectedBrand?["brand_name"] != widget.product!.brandName) {
                  body["brand_id"] = selectedBrand!["id"];
                }

                if (selectedCategory?["category_name"] !=
                    widget.product!.categoryName) {
                  body["category_id"] = selectedCategory!["id"];
                }

                // Assume isTaxable is always sent when changed manually
                body["is_taxable"] = isTaxable;

                // Always send update timestamp
                body["updatedAt"] = DateTime.now().toIso8601String();

                Map<String, dynamic>? res;
                try {
                  if (files.isNotEmpty) {
                    res = await putRequestWithFiles(
                      path: "/api/product/update-product/${widget.product!.id}",
                      data: body,
                      files: files,
                      requireToken: true,
                    );
                  } else {
                    res = await putRequest(
                      path: "/api/product/update-product/${widget.product!.id}",
                      body: body,
                      requireToken: true,
                    );
                  }
                } catch (e) {
                  Get.snackbar("Error", "Update failed: ${e.toString()}",
                      backgroundColor: Colors.red, colorText: Colors.white);
                  return;
                }

                if (res != null && res['id'] != null) {
                  print("Product updated!");
                } else {
                  Get.snackbar("Error", "Failed to update product.",
                      backgroundColor: Colors.red, colorText: Colors.white);
                  return;
                }
              }

              if (shouldUpdateQuantities) {
                Map<String, dynamic>? res;
                try {
                  res = await putRequest(
                    path:
                        "/api/main-warehouse-stock/update-products-quantities",
                    body: [
                      {
                        "product_id": widget.product!.id,
                        "box_quantity": boxQty,
                        "items_quantity": itemQty,
                      }
                    ],
                    requireToken: true,
                  );
                } catch (e) {
                  Get.snackbar(
                      "Error", "Quantity update failed: ${e.toString()}",
                      backgroundColor: Colors.red, colorText: Colors.white);
                  return;
                }

                if (res != null) {
                  print("Quantities updated!");
                } else {
                  Get.snackbar("Error", "Failed to update product quantities.",
                      backgroundColor: Colors.red, colorText: Colors.white);
                  return;
                }
              }

              if (!shouldUpdateProduct && !shouldUpdateQuantities) {
                print("No changes detected.");
              }

              productController.fetchProducts(); // Refresh table
              Navigator.pop(context);
              return;
            }

            // CREATE MODE – existing logic
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
          child: Text(widget.product == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}

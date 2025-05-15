import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/controllers/category_controller.dart';

class CategoryFormModal extends StatefulWidget {
  final bool isEdit;
  final int? categoryId;
  final String? initialName;

  const CategoryFormModal({
    super.key,
    required this.isEdit,
    this.categoryId,
    this.initialName,
  });

  @override
  State<CategoryFormModal> createState() => _CategoryFormModalState();
}

class _CategoryFormModalState extends State<CategoryFormModal> {
  final TextEditingController nameController = TextEditingController();
  File? selectedImage;
  String? existingImageUrl;
  Uint8List? selectedImageBytes; // for preview on web
  String? selectedImageFileName; // optional

  final CategoryController controller = Get.find();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.initialName != null) {
      nameController.text = widget.initialName!;
      // Load current image from controller
      final category = controller.categories
          .firstWhereOrNull((cat) => cat.id == widget.categoryId);
      existingImageUrl = category?.categoryImageUrl;
    }
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // Required for web!
    );

    if (result != null) {
      selectedImageFileName = result.files.first.name;

      if (kIsWeb && result.files.first.bytes != null) {
        selectedImageBytes = result.files.first.bytes;
        // Still assign a dummy File for backend compatibility
        selectedImage = File.fromRawPath(selectedImageBytes!);
      } else {
        selectedImage = File(result.files.first.path!);
        selectedImageBytes = null;
      }

      setState(() {});
    }
  }

  Future<void> handleSubmit() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    bool success = false;

    if (widget.isEdit) {
      success = await controller.updateCategory(widget.categoryId!, name,
          kIsWeb ? selectedImageBytes : selectedImage);
    } else {
      success = await controller.createCategory(
          name, kIsWeb ? selectedImageBytes : selectedImage);
    }

    if (success) Get.back(); // Close modal on success
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //Header
      title: Text(widget.isEdit ? 'Edit Category' : 'Create Category'),

      //Body
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //Category Name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),

            const SizedBox(height: 12),

            //Image Picker
            ElevatedButton(
              onPressed: pickImage,
              child: Text("Pick Image"),
            ),

            //Image Preview
            if (kIsWeb && selectedImageBytes != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.memory(selectedImageBytes!, height: 80),
              )
            else if (selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.file(selectedImage!, height: 80),
              )
            else if (existingImageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.network(existingImageUrl!, height: 80),
              )
          ],
        ),
      ),

      //Footer
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: handleSubmit,
          child: Text(widget.isEdit ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}

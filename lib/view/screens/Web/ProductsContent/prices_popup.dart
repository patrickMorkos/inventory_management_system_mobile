import 'package:flutter/material.dart';
import 'package:inventory_management_system_mobile/core/models/product_model.dart';

class PricesPopup extends StatefulWidget {
  final ProductModel product;

  const PricesPopup({super.key, required this.product});

  @override
  State<PricesPopup> createState() => _PricesPopupState();
}

class _PricesPopupState extends State<PricesPopup> {
  bool _isEditing = false;

  late Map<String, List<TextEditingController>> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      "A1": [
        TextEditingController(text: widget.product.boxPriceA1?.toString()),
        TextEditingController(text: widget.product.itemPriceA1?.toString())
      ],
      "A2": [
        TextEditingController(text: widget.product.boxPriceA2?.toString()),
        TextEditingController(text: widget.product.itemPriceA2?.toString())
      ],
      "B1": [
        TextEditingController(text: widget.product.boxPriceB1?.toString()),
        TextEditingController(text: widget.product.itemPriceB1?.toString())
      ],
      "B2": [
        TextEditingController(text: widget.product.boxPriceB2?.toString()),
        TextEditingController(text: widget.product.itemPriceB2?.toString())
      ],
      "C1": [
        TextEditingController(text: widget.product.boxPriceC1?.toString()),
        TextEditingController(text: widget.product.itemPriceC1?.toString())
      ],
      "C2": [
        TextEditingController(text: widget.product.boxPriceC2?.toString()),
        TextEditingController(text: widget.product.itemPriceC2?.toString())
      ],
      "D1": [
        TextEditingController(text: widget.product.boxPriceD1?.toString()),
        TextEditingController(text: widget.product.itemPriceD1?.toString())
      ],
      "D2": [
        TextEditingController(text: widget.product.boxPriceD2?.toString()),
        TextEditingController(text: widget.product.itemPriceD2?.toString())
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<double?>> prices = {
      "A1": [widget.product.boxPriceA1, widget.product.itemPriceA1],
      "A2": [widget.product.boxPriceA2, widget.product.itemPriceA2],
      "B1": [widget.product.boxPriceB1, widget.product.itemPriceB1],
      "B2": [widget.product.boxPriceB2, widget.product.itemPriceB2],
      "C1": [widget.product.boxPriceC1, widget.product.itemPriceC1],
      "C2": [widget.product.boxPriceC2, widget.product.itemPriceC2],
      "D1": [widget.product.boxPriceD1, widget.product.itemPriceD1],
      "D2": [widget.product.boxPriceD2, widget.product.itemPriceD2],
    };

    return AlertDialog(
      title: const Text("Product Prices"),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text("Class")),
            DataColumn(label: Text("Box Price")),
            DataColumn(label: Text("Item Price")),
          ],
          rows: prices.entries.map((entry) {
            return DataRow(cells: [
              DataCell(Text(entry.key)),
              DataCell(_isEditing
                  ? TextField(
                      controller: _controllers[entry.key]![0],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(isDense: true))
                  : Text(_controllers[entry.key]![0].text.isEmpty
                      ? "-"
                      : double.parse(_controllers[entry.key]![0].text)
                          .toStringAsFixed(2))),
              DataCell(_isEditing
                  ? TextField(
                      controller: _controllers[entry.key]![1],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(isDense: true))
                  : Text(_controllers[entry.key]![1].text.isEmpty
                      ? "-"
                      : double.parse(_controllers[entry.key]![1].text)
                          .toStringAsFixed(2))),
            ]);
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_isEditing) {
              final updatedPrices = _controllers.map((key, value) => MapEntry(
                    key,
                    [
                      double.tryParse(value[0].text),
                      double.tryParse(value[1].text)
                    ],
                  ));
              print("Updated Prices: $updatedPrices");
            }
            setState(() {
              _isEditing = !_isEditing;
            });
          },
          child: Text(_isEditing ? "Save" : "Edit"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    );
  }
}

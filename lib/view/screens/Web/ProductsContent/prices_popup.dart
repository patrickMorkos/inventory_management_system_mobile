import 'package:flutter/material.dart';
import 'package:inventory_management_system_mobile/core/models/product_model.dart';

class PricesPopup extends StatelessWidget {
  final ProductModel product;

  const PricesPopup({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<double?>> prices = {
      "A": [
        product.boxPriceA1,
        product.itemPriceA1,
        product.boxPriceA2,
        product.itemPriceA2
      ],
      "B": [
        product.boxPriceB1,
        product.itemPriceB1,
        product.boxPriceB2,
        product.itemPriceB2
      ],
      "C": [
        product.boxPriceC1,
        product.itemPriceC1,
        product.boxPriceC2,
        product.itemPriceC2
      ],
      "D": [
        product.boxPriceD1,
        product.itemPriceD1,
        product.boxPriceD2,
        product.itemPriceD2
      ],
    };

    return AlertDialog(
      title: const Text("Product Prices"),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text("Class")),
            DataColumn(label: Text("Box 1")),
            DataColumn(label: Text("Item 1")),
            DataColumn(label: Text("Box 2")),
            DataColumn(label: Text("Item 2")),
          ],
          rows: prices.entries.map((entry) {
            return DataRow(cells: [
              DataCell(Text(entry.key)),
              DataCell(Text(entry.value[0]?.toStringAsFixed(2) ?? "-")),
              DataCell(Text(entry.value[1]?.toStringAsFixed(2) ?? "-")),
              DataCell(Text(entry.value[2]?.toStringAsFixed(2) ?? "-")),
              DataCell(Text(entry.value[3]?.toStringAsFixed(2) ?? "-")),
            ]);
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Placeholder for future edit logic
            Navigator.of(context).pop();
          },
          child: const Text("Edit"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    );
  }
}

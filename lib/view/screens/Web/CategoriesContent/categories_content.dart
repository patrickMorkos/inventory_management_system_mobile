import 'package:flutter/material.dart';
import 'categories_table.dart';

class CategoriesContent extends StatelessWidget {
  const CategoriesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CategoriesTable(),
      ),
    );
  }
}

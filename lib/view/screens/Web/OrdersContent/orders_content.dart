import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/controllers/web_order_controller.dart';
import 'orders_table.dart';

class OrdersContent extends StatelessWidget {
  OrdersContent({super.key});
  final controller = Get.put(WebOrderController());

  @override
  Widget build(BuildContext context) {
    controller.fetchOrders();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: OrdersTable(),
    );
  }
}

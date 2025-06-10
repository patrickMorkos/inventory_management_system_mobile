import 'package:flutter/material.dart';

class EmptyScreenWidget extends StatelessWidget {
  const EmptyScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        children: [
          // Image.asset("images/empty_screen.png"),
          const SizedBox(height: 30),
          const Text(
            "No Data",
            style: TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }
}

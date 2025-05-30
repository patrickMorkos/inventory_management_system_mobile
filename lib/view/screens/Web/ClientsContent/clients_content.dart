import 'package:flutter/material.dart';

class ClientsContent extends StatelessWidget {
  const ClientsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text("Clients Content"),
        ),
      ),
    );
  }
}

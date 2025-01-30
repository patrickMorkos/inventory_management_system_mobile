import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:inventory_management_system_mobile/core/controllers/client_controller.dart';
import 'package:inventory_management_system_mobile/core/controllers/logged_in_user_controller.dart';
import 'package:inventory_management_system_mobile/data/api_service.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

class ReturnProductScreen extends StatefulWidget {
  const ReturnProductScreen({super.key});

  @override
  State<ReturnProductScreen> createState() => _ReturnProductScreenState();
}

class _ReturnProductScreenState extends State<ReturnProductScreen> {
  final ClientController clientController = Get.put(ClientController());
  final LoggedInUserController loggedInUserController =
      Get.put(LoggedInUserController());

  List<Map<String, Object>> clientStockProducts = [];
  List<dynamic> returnReasons = [];

  dynamic selectedProduct;
  int quantity = 1;
  dynamic selectedReason;

  @override
  void initState() {
    super.initState();
    fetchClientStockProducts();
    fetchReturnReasons();
  }

  Future<void> fetchClientStockProducts() async {
    var response = await getRequest(
      path:
          "/api/client-stock/get-all-client-stock-products/${clientController.clientInfo["id"]}",
      requireToken: true,
    );

    setState(() {
      if (response is List) {
        clientStockProducts = response
            .map((item) => (item as Map).cast<String, Object>())
            .toList();
      }
    });
  }

  Future<void> fetchReturnReasons() async {
    var response = await getRequest(
        path: "/api/returned-products/get-all-returned-products-reasons",
        requireToken: true);
    setState(() {
      returnReasons = response;
    });
  }

  Widget renderQuantityPickUp(sh) {
    return Container(
      width: double.infinity,
      color: Colors.red,
      child: InputQty(
        maxVal: selectedProduct?["quantity"] ?? 1,
        decoration: QtyDecorationProps(
          btnColor: kMainColor,
          fillColor: Colors.white,
        ),
        onQtyChanged: (value) {
          if (value is num) {
            setState(() {
              quantity = value.toInt();
            });
          }
        },
      ),
    );
  }

  void submitReturn() async {
    if (selectedProduct == null || selectedReason == null || quantity <= 0) {
      Fluttertoast.showToast(
          msg: "Please fill in all fields", gravity: ToastGravity.BOTTOM);
      return;
    }

    var response = await postRequest(
      path:
          "/api/returned-products/create-returned-product/${loggedInUserController.loggedInUser.value.id}",
      body: {
        "client_id": clientController.clientInfo["id"],
        "product_id": selectedProduct["Product"]["id"],
        "quantity": quantity,
        "returned_product_reason_id": selectedReason["id"]
      },
      requireToken: true,
    );

    if (response['error'] == null) {
      Fluttertoast.showToast(
          msg: "Product returned successfully!", gravity: ToastGravity.BOTTOM);
      Get.back();
    } else {
      Fluttertoast.showToast(
          msg: "Error: ${response['error']}",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red);
    }
  }

  AppBar renderAppBar() {
    return AppBar(
      backgroundColor: kMainColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: const Icon(
        Icons.arrow_back,
        color: Colors.white,
      ).onTap(() => Get.toNamed("/dashboard")),
      title: Text(
        "Return Product",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget renderProductsDropDown() {
    return DropdownSearch<Map<String, dynamic>>(
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            labelText: "Search Product",
            border: OutlineInputBorder(),
          ),
        ),
      ),
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: "Select Product to Return",
          border: OutlineInputBorder(),
        )
      ),
      items: (filter, infiniteScrollProps) => clientStockProducts,
      itemAsString: (product) =>
          "${product["Product"]["Brand"]["brand_name"]} - ${product["Product"]["name"]}",
      compareFn: (item1, item2) =>
          item1["Product"]["id"] == item2["Product"]["id"],
      onChanged: (value) {
        setState(() {
          selectedProduct = value;
        });
      },
      selectedItem: selectedProduct,
    );
  }

  Widget renderReturnReason() {
    return DropdownButtonFormField(
      decoration: const InputDecoration(
        labelText: "Return Reason",
        border: OutlineInputBorder(),
      ),
      value: selectedReason,
      items: returnReasons.map((reason) {
        return DropdownMenuItem(
          value: reason,
          child: Text(reason["reason"]),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedReason = value;
        });
      },
    );
  }

  Widget renderSaveButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: kMainColor, minimumSize: Size(double.infinity, 50)),
      onPressed: submitReturn,
      child: const Text(
        "Return Product",
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: kMainColor,
        appBar: renderAppBar(),
        body: Container(
          alignment: Alignment.topCenter,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              topLeft: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                renderProductsDropDown(),
                const SizedBox(height: 20),
                renderReturnReason(),
                const SizedBox(height: 20),
                renderQuantityPickUp(sh),
                const SizedBox(height: 30),
                renderSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

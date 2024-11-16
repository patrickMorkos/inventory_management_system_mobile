//! Van Categories screen UI
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:inventory_management_system_mobile/view/widgets/empty_screen_widget.dart';
import 'package:nb_utils/nb_utils.dart';

class VanCategoriesScreen extends StatefulWidget {
  const VanCategoriesScreen({super.key});

  @override
  State<VanCategoriesScreen> createState() => _VanCategoriesScreenState();
}

class _VanCategoriesScreenState extends State<VanCategoriesScreen> {
  //******************************************************************VARIABLES

  //This variable is the list of all the categories that will be listed
  //TODO - replace categories list from constants

  //This variable is a text editing controller for the search bar
  TextEditingController searchEditController = TextEditingController();

  //This variable is the list of all the categories after search
  List<dynamic> searchedCategoriesList = [];

  //This variable is the value entered for search
  String searchedCategory = "";

  //******************************************************************FUNCTIONS

  @override
  void initState() {
    super.initState();
    setState(() {
      searchedCategoriesList = categoriesList;
    });
  }

  //This function renders the categories list
  Widget renderCategoriesListing() {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: getCategoriesCards(),
          ),
        ),
      ),
    );
  }

  //This function returns the categories cards list
  List<Widget> getCategoriesCards() {
    List<Widget> tmp = [];
    if (searchedCategoriesList.isEmpty) {
      tmp.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 60),
            child: EmptyScreenWidget(),
          ),
        ),
      );
    } else {
      for (var element in searchedCategoriesList) {
        tmp.add(
          ListTile(
            onTap: () {
              Get.toNamed("/van-products");
            },
            leading: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kBorderColorTextField),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(element["category_picture_url"]),
                ),
              ),
            ),
            title: Text(
              element["category_name"],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
        tmp.add(
          const SizedBox(
            height: 20,
            child: Divider(),
          ),
        );
      }
    }

    return tmp;
  }

  // This function open the barcode scanner
  Future<void> openBarcodeScanner(sw, sh) async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancel",
        true,
        ScanMode.BARCODE,
      );
    } on PlatformException {
      barcodeScanRes = "Failed to get platform version.";
    }
    if (!mounted) return;
    searchCategory(barcodeScanRes, sw, sh);
  }

  //This function search for the category barcode inside the list of categories
  void searchCategory(String barcode, sw, sh) {
    //Condition if the barcode scanning is canceled
    if (barcode == "-1") {
      searchedCategoriesList = categoriesList;
    }

    //Condition if the scanned barcode is found
    if (searchedCategoriesList
        .any((element) => element["barcode"] == barcode)) {
      setState(() {
        searchedCategoriesList = categoriesList.where((element) {
          return element["barcode"]
              .toString()
              .toLowerCase()
              .contains(barcode.toLowerCase());
        }).toList();
      });
    } else {
      searchedCategoriesList = categoriesList;
    }
  }

  //This function renders the app bar
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
        "Van Categories List",
        style: GoogleFonts.poppins(
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  //This function renders the search bar
  Widget renderSearchBar(sw, sh) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
      child: AppTextField(
        controller: searchEditController,
        textFieldType: TextFieldType.NAME,
        onChanged: (value) {
          setState(() {
            searchedCategoriesList = categoriesList.where((element) {
              return element["category_name"]
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase());
            }).toList();
          });
          if (value.isEmpty) {
            setState(() {
              searchedCategoriesList = categoriesList;
            });
          }
          setState(() {
            searchedCategory = value;
          });
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelText: "Category Name",
          hintText: "Enter Category Name",
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IntrinsicWidth(
            child: IconButton(
              onPressed: () {
                setState(() {
                  searchedCategoriesList = categoriesList;
                  searchEditController.text = "";
                });
              },
              icon: const Icon(
                Icons.cancel_outlined,
                color: kMainColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //This variable is the screen width
    double sw = MediaQuery.of(context).size.width;

    //This variable is the screen height
    double sh = MediaQuery.of(context).size.height;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20.0),
              //Search bar
              renderSearchBar(sw, sh),

              //Categories list
              renderCategoriesListing()
            ],
          ),
        ),
      ),
    );
  }
}

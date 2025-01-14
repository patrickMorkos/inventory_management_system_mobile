import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventory_management_system_mobile/core/controllers/logged_in_user_controller.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:inventory_management_system_mobile/view/widgets/empty_screen_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:inventory_management_system_mobile/data/api_service.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  //******************************************************************VARIABLES

  // This variable is the list of all clients
  List<dynamic> clientsList = [];

  // This variable is a text editing controller for the search bar
  TextEditingController searchEditController = TextEditingController();

  // This variable is the list of all clients after search
  List<dynamic> searchedClientsList = [];

  // This variable is the value entered for search
  String searchedClient = "";

  //This variable is the logged in user controller
  final LoggedInUserController loggedInUserController =
      Get.put(LoggedInUserController());

  //******************************************************************FUNCTIONS

  // This function calls the API to get all clients for the salesman
  Future<void> getClients() async {
    await getRequest(
      path:
          "/api/client/get-client-by-salesman/${loggedInUserController.loggedInUser.value.id}",
      requireToken: true,
    ).then((value) {
      setState(() {
        clientsList = value;
        searchedClientsList = clientsList;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getClients();
  }

  // This function renders the clients list
  Widget renderClientsListing() {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: getClientsCards(),
          ),
        ),
      ),
    );
  }

  // This function returns the client cards list
  List<Widget> getClientsCards() {
    List<Widget> tmp = [];
    if (searchedClientsList.isEmpty) {
      tmp.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 60),
            child: EmptyScreenWidget(),
          ),
        ),
      );
    } else {
      for (var element in searchedClientsList) {
        tmp.add(
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Icon(
                Icons.person,
                color: Colors.grey[600],
              ),
            ),
            title: Text(
              "${element['Client']['first_name']} ${element['Client']['last_name']}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "Company: ${element['Client']['company_name']}\n"
              "Phone: ${element['Client']['phone_number']}\n"
              "Address: ${element['Client']['address']}",
              maxLines: 3,
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

  // This function renders the app bar
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
        "Clients",
        style: GoogleFonts.poppins(
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  // This function renders the search bar
  Widget renderSearchBar(sw, sh) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
      child: AppTextField(
        controller: searchEditController,
        textFieldType: TextFieldType.NAME,
        onChanged: (value) {
          setState(() {
            searchedClientsList = clientsList.where((element) {
              return element['Client']['first_name']
                      .toString()
                      .toLowerCase()
                      .contains(value.toLowerCase()) ||
                  element['Client']['last_name']
                      .toString()
                      .toLowerCase()
                      .contains(value.toLowerCase()) ||
                  element['Client']['company_name']
                      .toString()
                      .toLowerCase()
                      .contains(value.toLowerCase());
            }).toList();
          });
          if (value.isEmpty) {
            setState(() {
              searchedClientsList = clientsList;
            });
          }
          setState(() {
            searchedClient = value;
          });
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelText: "Client Name",
          hintText: "Enter Client Name",
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IntrinsicWidth(
            child: IconButton(
              onPressed: () {
                setState(() {
                  searchedClientsList = clientsList;
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
    // This variable is the screen width
    double sw = MediaQuery.of(context).size.width;

    // This variable is the screen height
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
              // Search bar
              renderSearchBar(sw, sh),

              // Clients list
              renderClientsListing(),
            ],
          ),
        ),
      ),
    );
  }
}

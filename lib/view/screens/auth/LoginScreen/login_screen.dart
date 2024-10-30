//! Login screen UI
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:inventory_management_system_mobile/core/controllers/logged_in_user_controller.dart';
import 'package:inventory_management_system_mobile/core/models/user_model.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:inventory_management_system_mobile/data/api_service.dart';
import 'package:inventory_management_system_mobile/view/widgets/button_global.dart';
import 'package:nb_utils/nb_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //******************************************************************VARIABLES
  //This variable is the login controller
  final LoggedInUserController loggedInUserController =
      Get.put(LoggedInUserController());

  //This variable is the show password flag
  bool showPassword = true;

  //These variables are the email and password inserted by the user
  late String email, password;

  //This variable is the global key for the login form
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  //This variable is for the wifi connection
  late StreamSubscription subscription;

  //This variable is a flag to check either the phone is connected to the wifi or not
  bool isDeviceConnected = false;

  //This variable is a flag to either show the alert that phone is not connected to wifi or not
  bool isAlertSet = false;

  //******************************************************************FUNCTIONS

  //This function validate the email and password input
  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  //This function is to check for internet connectivity
  void connectivityCallback(List<ConnectivityResult> results) async {
    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    if (!isDeviceConnected && !isAlertSet) {
      showDialogBox();
      setState(() => isAlertSet = true);
    }
  }

  //This function is to get the devices connectivity
  getConnectivity() {
    if (kIsWeb) {
      return;
    }
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      connectivityCallback(results);
    });
  }

  //This function check the internet connection as well
  checkInternet() async {
    if (kIsWeb) {
      return;
    }

    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    if (!isDeviceConnected) {
      showDialogBox();
      setState(() => isAlertSet = true);
    }
  }

  //This function logs the user in execute the api call and redirect to the dashboard
  void login() async {
    Map body = {
      "email": email,
      "password": password,
    };
    UserModel user = UserModel(
      id: 0,
      firstName: "",
      lastName: "",
      phoneNumber: "",
      email: "",
      password: "",
      dateOfBirth: "",
      dateOfJoin: "",
    );
    String accessToken = "";
    await postRequest(path: "/api/auth/login", body: body).then((value) {
      user = UserModel.fromMap(value['user']);
      accessToken = value['token'];
    });
    loggedInUserController.setUserInfo(user, accessToken);
    Get.toNamed('/dashboard');
  }

  //This function shows the alert dialog
  showDialogBox() => showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text("No Connection"),
          content: const Text("Please check your internet connectivity"),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Cancel');
                setState(() => isAlertSet = false);
                isDeviceConnected =
                    await InternetConnectionChecker().hasConnection;
                if (!isDeviceConnected && isAlertSet == false) {
                  showDialogBox();
                  setState(() => isAlertSet = true);
                }
              },
              child: const Text("Try Again"),
            ),
          ],
        ),
      );

  @override
  void initState() {
    getConnectivity();
    checkInternet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Consumer(builder: (context, ref, child) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Login log
                  Image.asset(
                    loginScreenLogo,
                    height: 150,
                    width: 150,
                  ),

                  //Login form
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      key: globalKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          //Email input
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Email",
                              hintText: "Enter Your Email Address",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email can\'t be empty';
                              } else if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              email = value!;
                            },
                          ),
                          const SizedBox(height: 20),
                          //Passwprd input
                          TextFormField(
                            keyboardType: TextInputType.text,
                            obscureText: showPassword,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: "Password",
                              hintText: "Enter Your Email Address",
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                                icon: Icon(showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password can\'t be empty';
                              } else if (value.length < 4) {
                                return 'Please enter a bigger password';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              password = value!;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  //Login button
                  ButtonGlobal(
                    buttontext: "Login",
                    buttonDecoration:
                        kButtonDecoration.copyWith(color: kMainColor),
                    onPressed: () {
                      if (validateAndSave()) {
                        login();
                      }
                    },
                    iconWidget: null,
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

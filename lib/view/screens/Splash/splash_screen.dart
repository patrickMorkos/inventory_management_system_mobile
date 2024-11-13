//! This is the splash screen that shoes for 1 second when the app in opened
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:inventory_management_system_mobile/view/screens/Login/login_screen.dart';

class SplashScreen extends StatelessWidget {
  //******************************************************************VARIABLES

  //This is the constructor of the Splash Screen
  const SplashScreen({
    super.key,
  });

  //******************************************************************FUNCTIONS

  //This function renders the logo
  Widget renderLogo(sw, sh) {
    return SizedBox(
      height: sw,
      width: sw,
      child: Image.asset("assets/images/logo.png"),
    );
  }

  @override
  Widget build(BuildContext context) {
    //This variable is the screen width
    double sw = MediaQuery.of(context).size.width;

    //This variable is the screen height
    double sh = MediaQuery.of(context).size.height;

    return SafeArea(
      child: AnimatedSplashScreen(
        backgroundColor: kMainColor,
        splash: renderLogo(sw, sh),
        nextScreen: const LoginScreen(),
      ),
    );
  }
}

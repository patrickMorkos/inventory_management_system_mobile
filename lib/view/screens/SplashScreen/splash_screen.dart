import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:inventory_management_system_mobile/view/screens/auth/LoginScreen/login_screen.dart';

class SplashScreen extends StatelessWidget {
  //This is the constructor of the Splash Screen
  const SplashScreen({
    super.key,
  });

  //This function renders the logo
  Widget renderLogo(sw, sh) {
    return SizedBox(
      height: sw,
      width: sw,
      child: Image.asset("assets/images/Logo.png"),
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
        backgroundColor: primaryColor,
        splash: renderLogo(sw, sh),
        nextScreen: const LoginScreen(),
      ),
    );
  }
}

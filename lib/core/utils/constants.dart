//! These are constants globaly used
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

//The main color of the app
const kMainColor = Color(0xff8424FF);

const kBorderColorTextField = Color(0xFFC2C2C2);
const kDarkWhite = Color(0xFFF1F7F7);
const kTitleColor = Color(0xFF000000);
const kGreyTextColor = Color(0xFF828282);
const kBorderColor = Color(0xff7D7D7D);
bool isReportShow = false;
final kTextStyle = GoogleFonts.manrope(
  color: Colors.white,
);

//The login screen logo
const String loginScreenLogo = 'assets/images/sblogo.png';

//The app name
const String appName = 'Inventory Management System';

//The host
//TODO change the host on deployment
// const String ip = "192.168.0.102";
// const String host = 'http://$ip:3000';
const String host = 'https://api.yallalift.com';

//A button decoration
const kButtonDecoration = BoxDecoration(
  borderRadius: BorderRadius.all(
    Radius.circular(5),
  ),
);

double getResponsiveSize(size) {
  return (size * Get.context!.mediaQueryShortestSide) / 1080;
}

final List<Color> accentColors = const [
  Color(0xFFDEF3F6),
  Color(0xFFFADADD),
  Color(0xFFE8EAF6),
  Color(0xFFE1F5FE),
  Color(0xFFF1F8E9),
  Color(0xFFFFF8E1),
];

//! These are constants globaly used
import 'package:flutter/material.dart';
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
const String ip = "192.168.0.107";
const String host = 'http://$ip:3000';

//A button decoration
const kButtonDecoration = BoxDecoration(
  borderRadius: BorderRadius.all(
    Radius.circular(5),
  ),
);
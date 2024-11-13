import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

class ButtonGlobal extends StatelessWidget {
  final dynamic iconWidget;
  final String buttontext;
  final Color iconColor;
  final Decoration buttonDecoration;
  final dynamic onPressed;

  const ButtonGlobal({
    super.key,
    required this.iconWidget,
    required this.buttontext,
    required this.iconColor,
    required this.buttonDecoration,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        decoration: buttonDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttontext,
              style: GoogleFonts.jost(fontSize: 20.0, color: Colors.white),
            ),
            Icon(
              iconWidget,
              color: iconColor,
            ).visible(false),
          ],
        ),
      ),
    );
  }
}

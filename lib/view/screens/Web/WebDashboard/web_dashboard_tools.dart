import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SidebarTile extends StatelessWidget {
  const SidebarTile({
    super.key,
    required this.title,
    this.iconPath,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String? iconPath;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        color: selected ? Colors.white : Colors.transparent,
        child: Row(
          children: [
            if (iconPath != null)
              Image.asset(iconPath!, width: 20, height: 20, color: Colors.white)
            else if (icon != null)
              Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

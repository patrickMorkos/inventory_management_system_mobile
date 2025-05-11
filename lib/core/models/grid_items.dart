import 'package:flutter/material.dart';

class GridItems {
  final String title, icon, route;
  final bool showCard;
  final Widget? content;

  GridItems({
    required this.route,
    required this.title,
    required this.icon,
    required this.showCard,
    this.content,
  });
}

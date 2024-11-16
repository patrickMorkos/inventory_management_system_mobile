import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/models/grid_items.dart';

class DashboardGridCards extends StatefulWidget {
  //Widget parameters
  final GridItems gridItems;
  final Color color;

  //Widget constructor
  const DashboardGridCards({
    super.key,
    required this.gridItems,
    required this.color,
  });

  @override
  State<DashboardGridCards> createState() => _DashboardGridCardsState();
}

class _DashboardGridCardsState extends State<DashboardGridCards> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Grid card circle
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            border: Border.all(
              color: widget.color,
            ),
          ),
          child: TextButton(
            onPressed: () {
              if (kDebugMode) {
                print("navigate to screen");
              }
              Get.toNamed(widget.gridItems.route);
            },
            child: SvgPicture.asset(
              widget.gridItems.icon,
              height: 40.0,
              width: 40.0,
              allowDrawingOutsideViewBox: false,
              fit: BoxFit.contain,
            ),
          ),
        ),

        //Grid card title
        Text(
          widget.gridItems.title.toString(),
          style: const TextStyle(fontSize: 13, color: Colors.black),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}

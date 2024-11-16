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
const String host = 'http://localhost:3000';

//A button decoration
const kButtonDecoration = BoxDecoration(
  borderRadius: BorderRadius.all(
    Radius.circular(5),
  ),
);

List<dynamic> productsList = [
  {
    "product_name": "Hummus",
    "product_brand": "Cedar's",
    "quantity": 50,
    "price": 4.99,
    "product_barcode": "1234567890123",
    "product_picture_url":
        "https://www.cedarsfoods.com/getattachment/6d75f738-e617-4c9d-8b56-8c67db2f4c54/Fat-Oil-Free-Original.aspx"
  },
  {
    "product_name": "Iqos Amber",
    "product_brand": "Terrea",
    "quantity": 30,
    "price": 3,
    "product_barcode": "7622100966487",
    "product_picture_url":
        "https://outleb.com/wp-content/uploads/2022/07/55fbbcd7838031bd7c5306ce0d64d131e5bf6972-1-600x503.jpg"
  },
  {
    "product_name": "Baba Ghanoush",
    "product_brand": "Mediterranean Delights",
    "quantity": 40,
    "price": 5.99,
    "product_barcode": "3456789012345",
    "product_picture_url":
        "https://www.cedarsfoods.com/getattachment/6d75f738-e617-4c9d-8b56-8c67db2f4c54/Fat-Oil-Free-Original.aspx"
  },
  {
    "product_name": "Falafel Mix",
    "product_brand": "Lebanese Kitchen",
    "quantity": 25,
    "price": 3.99,
    "product_barcode": "4567890123456",
    "product_picture_url":
        "https://www.cedarsfoods.com/getattachment/6d75f738-e617-4c9d-8b56-8c67db2f4c54/Fat-Oil-Free-Original.aspx"
  },
  {
    "product_name": "Pita Bread",
    "product_brand": "Cedars Bakery",
    "quantity": 60,
    "price": 2.99,
    "product_barcode": "5678901234567",
    "product_picture_url":
        "https://www.cedarsfoods.com/getattachment/6d75f738-e617-4c9d-8b56-8c67db2f4c54/Fat-Oil-Free-Original.aspx"
  },
  {
    "product_name": "Labneh",
    "product_brand": "Dairy Land",
    "quantity": 35,
    "price": 4.49,
    "product_barcode": "6789012345678",
    "product_picture_url":
        "https://www.cedarsfoods.com/getattachment/6d75f738-e617-4c9d-8b56-8c67db2f4c54/Fat-Oil-Free-Original.aspx"
  },
  {
    "product_name": "Kibbeh",
    "product_brand": "Oriental Foods",
    "quantity": 20,
    "price": 6.99,
    "product_barcode": "7890123456789",
    "product_picture_url":
        "https://www.cedarsfoods.com/getattachment/6d75f738-e617-4c9d-8b56-8c67db2f4c54/Fat-Oil-Free-Original.aspx"
  },
  {
    "product_name": "Stuffed Grape Leaves",
    "product_brand": "Mediterranean Delights",
    "quantity": 45,
    "price": 5.99,
    "product_barcode": "8901234567890",
    "product_picture_url":
        "https://www.cedarsfoods.com/getattachment/6d75f738-e617-4c9d-8b56-8c67db2f4c54/Fat-Oil-Free-Original.aspx"
  },
  {
    "product_name": "Shawarma Spice Mix",
    "product_brand": "Spice World",
    "quantity": 50,
    "price": 3.49,
    "product_barcode": "9012345678901",
    "product_picture_url":
        "https://www.cedarsfoods.com/getattachment/6d75f738-e617-4c9d-8b56-8c67db2f4c54/Fat-Oil-Free-Original.aspx"
  },
  {
    "product_name": "Za'atar",
    "product_brand": "Herbal Essence",
    "quantity": 55,
    "price": 2.99,
    "product_barcode": "0123456789012",
    "product_picture_url":
        "https://www.cedarsfoods.com/getattachment/6d75f738-e617-4c9d-8b56-8c67db2f4c54/Fat-Oil-Free-Original.aspx"
  },
  {
    "product_name": "Tahini",
    "product_brand": "Sesame King",
    "quantity": 40,
    "price": 4.99,
    "product_barcode": "1123456789012",
    "product_picture_url":
        "https://www.cedarsfoods.com/getattachment/6d75f738-e617-4c9d-8b56-8c67db2f4c54/Fat-Oil-Free-Original.aspx"
  },
  {
    "product_name": "Baklava",
    "product_brand": "Sweet Delights",
    "quantity": 30,
    "price": 7.99,
    "product_barcode": "2123456789012",
    "product_picture_url":
        "https://www.cedarsfoods.com/getattachment/6d75f738-e617-4c9d-8b56-8c67db2f4c54/Fat-Oil-Free-Original.aspx"
  },
  {
    "product_name": "Mujadara",
    "product_brand": "Lebanese Kitchen",
    "quantity": 25,
    "price": 5.49,
    "product_barcode": "3123456789012",
    "product_picture_url":
        "https://www.cedarsfoods.com/getattachment/6d75f738-e617-4c9d-8b56-8c67db2f4c54/Fat-Oil-Free-Original.aspx"
  },
  {
    "product_name": "Fattoush Salad",
    "product_brand": "Beirut Bites",
    "quantity": 35,
    "price": 5.99,
    "product_barcode": "4123456789012",
    "product_picture_url":
        "https://www.cedarsfoods.com/getattachment/6d75f738-e617-4c9d-8b56-8c67db2f4c54/Fat-Oil-Free-Original.aspx"
  },
  {
    "product_name": "Kafta",
    "product_brand": "Oriental Foods",
    "quantity": 20,
    "price": 6.49,
    "product_barcode": "5123456789012",
    "product_picture_url":
        "https://www.cedarsfoods.com/getattachment/6d75f738-e617-4c9d-8b56-8c67db2f4c54/Fat-Oil-Free-Original.aspx"
  },
  {
    "product_name": "Manakish",
    "product_brand": "Cedars Bakery",
    "quantity": 30,
    "price": 3.99,
    "product_barcode": "6123456789012",
    "product_picture_url":
        "https://www.cedarsfoods.com/getattachment/6d75f738-e617-4c9d-8b56-8c67db2f4c54/Fat-Oil-Free-Original.aspx"
  },
  {
    "product_name": "Knafeh",
    "product_brand": "Sweet Delights",
    "quantity": 25,
    "price": 7.49,
    "product_barcode": "7123456789012",
    "product_picture_url":
        "https://www.cedarsfoods.com/getattachment/6d75f738-e617-4c9d-8b56-8c67db2f4c54/Fat-Oil-Free-Original.aspx"
  },
  {
    "product_name": "Arak",
    "product_brand": "Lebanese Spirits",
    "quantity": 15,
    "price": 19.99,
    "product_barcode": "8123456789012",
    "product_picture_url":
        "https://www.cedarsfoods.com/getattachment/6d75f738-e617-4c9d-8b56-8c67db2f4c54/Fat-Oil-Free-Original.aspx"
  },
  {
    "product_name": "Ma'amoul",
    "product_brand": "Sweet Delights",
    "quantity": 40,
    "price": 6.99,
    "product_barcode": "9123456789012",
    "product_picture_url":
        "https://www.cedarsfoods.com/getattachment/6d75f738-e617-4c9d-8b56-8c67db2f4c54/Fat-Oil-Free-Original.aspx"
  }
];
List<dynamic> categoriesList = [
  {
    "category_name": "Dips & Spreads",
    "category_picture_url":
        "https://uxwing.com/wp-content/themes/uxwing/download/signs-and-symbols/smoking-area-icon.png"
  },
  {
    "category_name": "Salads",
    "category_picture_url": "https://example.com/salads.png"
  },
  {
    "category_name": "Dry Mixes",
    "category_picture_url": "https://example.com/dry_mixes.png"
  },
  {
    "category_name": "Breads",
    "category_picture_url": "https://example.com/breads.png"
  },
  {
    "category_name": "Dairy",
    "category_picture_url": "https://example.com/dairy.png"
  },
  {
    "category_name": "Ready Meals",
    "category_picture_url": "https://example.com/ready_meals.png"
  },
  {
    "category_name": "Appetizers",
    "category_picture_url": "https://example.com/appetizers.png"
  },
  {
    "category_name": "Spices & Seasonings",
    "category_picture_url": "https://example.com/spices_seasonings.png"
  },
  {
    "category_name": "Condiments",
    "category_picture_url": "https://example.com/condiments.png"
  },
  {
    "category_name": "Desserts",
    "category_picture_url": "https://example.com/desserts.png"
  },
  {
    "category_name": "Beverages",
    "category_picture_url": "https://example.com/beverages.png"
  }
];

import 'package:flutter/material.dart';


class TSizes {

  static const EdgeInsetsGeometry paddingWithAppBarHeight = EdgeInsets.only(
    top: appBarHeight,
    left: defaultSpace,
    bottom: defaultSpace,
    right: defaultSpace
  );

  // Pading & Margin sizes
  static  const double xs = 4.0;
  static  const double sm = 8.0;
  static  const double md = 16.0;
  static  const double lg = 24.0;
  static  const double xl = 32.0;



  static BoxDecoration boxDecorationBorder(
      {required Color color,
        required double radius,
        Color? borderColor,
        double? borderWidth}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: borderColor == null
          ? null
          : Border.all(color: borderColor, width: borderWidth ?? 1),
    );
  }

  // Icon sizes
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;

  //Font sizes
  static const double fontSizeSm = 14.0;
  static const double fontSizeMd = 16.0;
  static const double fontSizeLg = 18.0;

  // Button Sizes
  static const double buttonHeigth = 18.0;
  static const double buttonRadius = 12.0;
  static const double buttonWidth = 120.0;
  static const double buttonElevation = 4.0;

  // AppBar height
  static const double appBarHeight = 56.0;

  // Image sizes
  static const double imageThumbSize = 80.0;

  // Default spaccing between sections
  static const double defaultSpace = 24.0;
  static const double spaceBtwItems = 16.0;
  static const double spaceBtwSections = 32.0;
  static const double customSpaceBtwSections = 64.0;

  // Border radius
  static const double borderRadiusSm  = 4.0;
  static const double borderRadiusMd  = 8.0;
  static const double borderRadiusLg  = 12.0;

  // Divider height
  static const double dividerHeight  = 1.0;

  // Input Field
static const double inputFieldRadius = 12.0;
static const double spaceBtwInputFields = 16.0;

// Card Sizes
static const double cardRadiusLg = 16.0;
  static const double cardRadiusMd = 12.0;
  static const double cardRadiusSm= 10.0;
  static const double cardRadiusXs = 6.0;

}
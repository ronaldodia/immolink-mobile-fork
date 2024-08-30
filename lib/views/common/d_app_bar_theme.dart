import 'package:flutter/material.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';

class DAppBarTheme {
  DAppBarTheme._();

  static const appBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: Colors.black, size: TSizes.iconMd),
    actionsIconTheme: IconThemeData(color: Colors.black, size: TSizes.iconMd),
    titleTextStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: Colors.black)
  );
}
import 'package:flutter/material.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';

class SpacingStyles{

  static const EdgeInsetsGeometry paddingWithAppBarHeight = EdgeInsets.only(
      top: TSizes.appBarHeight,
      left: TSizes.defaultSpace,
      bottom: TSizes.defaultSpace,
      right: TSizes.defaultSpace
  );
}
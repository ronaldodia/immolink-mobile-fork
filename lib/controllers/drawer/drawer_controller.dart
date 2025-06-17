import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDrawerController extends GetxController {
  static AppDrawerController get instance => Get.find();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }
}

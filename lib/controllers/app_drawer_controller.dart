import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDrawerController extends GetxController {
  static AppDrawerController? _instance;

  static AppDrawerController get instance {
    if (_instance == null) {
      _instance = Get.put(AppDrawerController());
    }
    return _instance!;
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  @override
  void onClose() {
    _instance = null;
    super.onClose();
  }
}

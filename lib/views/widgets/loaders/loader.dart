import 'dart:ui';

import 'package:get/get.dart';
import 'package:flutter/material.dart';

class DLoader {


  static successSnackBar({ required title, message = ''}){

    Get.snackbar(
        title,
        message,
        isDismissible: true,
        shouldIconPulse: true,
        colorText: Colors.white,
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        icon: const Icon(Icons.check, color: Colors.white,)
    );
  }

  static warningSnackBar({ required title, message = ''}){

    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: Colors.orange,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      icon: const Icon(Icons.warning, color: Colors.white,)
    );
  }


  static errorSnackBar({ required title, message = ''}){

    Get.snackbar(
        title,
        message,
        isDismissible: true,
        shouldIconPulse: true,
        colorText: Colors.white,
        backgroundColor: Colors.red.shade600,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(20),
        icon: const Icon(Icons.error, color: Colors.white,)
    );
  }
}
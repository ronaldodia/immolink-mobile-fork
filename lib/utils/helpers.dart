import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Helper {
  
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static getAssetName(String fileName){
    return "assets/images/$fileName";
  }

  static getAssetNameWithType(String fileName, String type){
    return "assets/images/$type/$fileName";
  }

  static void showSnackbar(String message) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text(message)));
  }

  static double getAppBarHeight() {
    return kToolbarHeight;
  }

  static void showAlert(String title, String message){
    showDialog(context: Get.context!, builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))
        ],
      );
    });
  }

}
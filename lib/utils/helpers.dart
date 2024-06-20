import 'package:flutter/material.dart';

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

}
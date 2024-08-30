import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/views/widgets/loaders/animation_loader.dart';

class FullscreenLoader {

  static void openDialog(String text, String animation) {
    showDialog(context: Get.overlayContext!,
        barrierDismissible: false,
        builder: (_) => PopScope(
        canPop: false,
        child: Container(
          color: Colors.white,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 250,),
              AnimationLoader(text: text, animation: animation, )
            ],
          ),
        )
    ));
  }

  /// Stop the currently open loading dialog
/// This method doesn't return anything.
  static stopLoading() {
    Navigator.of(Get.overlayContext!).pop();
  }
}
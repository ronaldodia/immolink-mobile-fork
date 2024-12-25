import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'package:immolink_mobile/models/LanguageModel.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/views/screens/bottom_navigation_menu.dart';
import 'package:immolink_mobile/views/widgets/loaders/animation_loader.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Language'.tr),  // Utilisation de .tr pour la traduction avec GetX
      ),
      body: Obx(() {
        var groupValue = languageController.locale.languageCode;

        return ListView.builder(
          itemCount: languageModel.length,
          itemBuilder: (context, index) {
            var item = languageModel[index];
            bool isSelected = item.languageCode == groupValue;
            return RadioListTile(
              value: item.languageCode,
              title: Text(item.language),
              subtitle: Text(item.subLanguage),
              groupValue: groupValue,
              onChanged: (value) {
                languageController.changeLanguage(item.languageCode);
                const AnimationLoader(text: 'Changement de langue en cours', animation: TImages.loading, );
                // Get.offAll(const BottomNavigationMenu());
                Get.back();
              },
            );
          },
        );
      }),
    );
  }
}

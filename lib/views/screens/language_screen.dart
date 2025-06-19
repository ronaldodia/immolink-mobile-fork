import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'package:immolink_mobile/models/LanguageModel.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/views/screens/bottom_navigation_menu.dart';
import 'package:immolink_mobile/views/screens/home_screen.dart';
import 'package:immolink_mobile/views/widgets/loaders/animation_loader.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  bool _isLoading = false;

  void _onLanguageSelected(String languageCode) async {
    setState(() {
      _isLoading = true;
    });
    final languageController = Get.find<LanguageController>();
    languageController.changeLanguage(languageCode);
    // Attendre un court instant pour laisser le temps à la langue de s'appliquer
    await Future.delayed(const Duration(milliseconds: 800));
    // Rediriger vers HomeScreen (ou BottomNavigationMenu si tu préfères)
    Get.offAll(() => const HomeScreen());
  }

  void showLanguagePicker(BuildContext context) {
    final LanguageController languageController =
        Get.find<LanguageController>();
    final groupValue = languageController.locale.languageCode;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text('Choisir la langue',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ...languageModel.map((item) => RadioListTile(
                  value: item.languageCode,
                  groupValue: groupValue,
                  title: Text(item.language),
                  subtitle: Text(item.subLanguage),
                  onChanged: (value) async {
                    languageController.changeLanguage(item.languageCode);
                    Navigator.of(context).pop();
                  },
                )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController = Get.find();

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Language'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => showLanguagePicker(context),
          ),
        ],
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
                _onLanguageSelected(item.languageCode);
              },
            );
          },
        );
      }),
    );
  }
}

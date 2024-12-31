import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:immolink_mobile/controllers/communes/commune_controller.dart';
import 'package:immolink_mobile/controllers/communes/district_controller.dart';
import 'package:immolink_mobile/controllers/home/categories_controller.dart';

class LanguageController extends GetxController {
  final GetStorage _box = GetStorage();
  final Rx<Locale> _locale = const Locale('en').obs;

  Locale get locale => _locale.value;

  @override
  void onInit() {
    super.onInit();
    String? savedLanguage = _box.read('language');
    if (savedLanguage != null) {
      _locale.value = Locale(savedLanguage);
    }
  }

  void changeLanguage(String languageCode) {
    Locale newLocale = Locale(languageCode);
    _locale.value = newLocale;
    Get.updateLocale(newLocale);
    _box.write('language', languageCode);

    // 3. Mettez à jour les données après le changement de langue
    updateUI();
    Get.back();
  }

  void updateUI() {
    // Mettez à jour les données (par exemple, actualisez les API ou le stockage local)
    // Exemple : Appeler un contrôleur pour recharger les données en fonction de la nouvelle langue
    Get.find<CategoryController>().fetchCategories(Get.locale?.languageCode ?? 'fr');
    // Get.find<CommuneController>().fetchCommunes(Get.locale?.languageCode ?? 'fr');
    // Get.find<DistrictController>().fetchDistricts(Get.locale?.languageCode ?? 'fr');
  }
}

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:immolink_mobile/controllers/communes/commune_controller.dart';
import 'package:immolink_mobile/controllers/communes/district_controller.dart';
import 'package:immolink_mobile/controllers/home/categories_controller.dart';

class LanguageController extends GetxController {
  final GetStorage _box = GetStorage();
  final Rx<Locale> _locale;

  // Permet d'injecter la locale initiale
  LanguageController(Locale initialLocale) : _locale = initialLocale.obs;

  Locale get locale => _locale.value;

  void changeLanguage(String languageCode) {
    Locale newLocale = Locale(languageCode);
    _locale.value = newLocale;
    Get.updateLocale(newLocale);
    _box.write('language', languageCode);
    updateUI();
  }

  void updateUI() {
    Get.find<CategoryController>()
        .fetchCategories(Get.locale?.languageCode ?? 'fr');
    // Get.find<CommuneController>().fetchCommunes(Get.locale?.languageCode ?? 'fr');
    // Get.find<DistrictController>().fetchDistricts(Get.locale?.languageCode ?? 'fr');
  }
}

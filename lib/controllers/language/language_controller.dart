import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

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
  }
}

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'dart:convert';

import 'package:immolink_mobile/utils/config.dart';

class CategoryController extends GetxController {
  var categories = [].obs;
  var isLoading = true.obs;
  var selectedCategory = ''.obs;
  var purpose = ''.obs;
  var bookableType = ''.obs;

  // Fonction pour récupérer les catégories
  Future<void> fetchCategories(String language) async {
    try {
      isLoading(true);
      print('${Config.baseUrlApp}/home/categories?language=$language');
      final response = await http.get(Uri.parse('${Config.baseUrlApp}/home/categories?language=$language'));
      // print(response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // print(data[0]['data']);
        categories.value = data[0]['data'];
      } else {
        // En cas d'erreur
        Get.snackbar("Error", "Failed to fetch categories");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch categories: $e");
    } finally {
      isLoading(false);
    }
  }

  void selectCategory(String categoryName) {
    selectedCategory.value = categoryName;
    updateBookableType(); // Met à jour le bookableType en fonction de la catégorie sélectionnée
  }

  void setPurpose(String purposeValue) {
    purpose.value = purposeValue;
    updateBookableType(); // Met à jour le bookableType en fonction de la catégorie et du purpose
  }

  void updateBookableType() {
    if (purpose.value == 'Rent') {
      if (selectedCategory.value == 'Apartment' || selectedCategory.value == 'شقة' || selectedCategory.value == 'Appartement') {
        bookableType.value = 'Daily, Monthly';
      } else if (selectedCategory.value == 'House' || selectedCategory.value == 'بيت' || selectedCategory.value == 'Maison') {
        bookableType.value = 'Daily, Monthly';
      } else if (selectedCategory.value == 'Store' || selectedCategory.value == 'محل' || selectedCategory.value == 'Boutique') {
        bookableType.value = 'Monthly';
      } else if (selectedCategory.value == 'Office' || selectedCategory.value == 'مكتب' || selectedCategory.value == 'Bureau') {
        bookableType.value = 'Monthly';
      }
    } else {
      bookableType.value = ''; // Pas de bookableType pour Sell
    }
  }

  @override
  void onInit() {
    super.onInit();
    final LanguageController language = Get.find(); // Valeur par défaut 'en' si la langue n'est pas trouvée
    fetchCategories(language.locale.languageCode);
  }
}

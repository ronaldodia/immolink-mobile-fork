import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'dart:convert';

import 'package:immolink_mobile/utils/config.dart';

class CategoryController extends GetxController {
  var categories = [].obs;
  var isLoading = true.obs;

  // Fonction pour récupérer les catégories
  Future<void> fetchCategories(String language) async {
    try {
      isLoading(true);
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

  @override
  void onInit() {
    super.onInit();
    final LanguageController language = Get.find(); // Valeur par défaut 'en' si la langue n'est pas trouvée
    fetchCategories(language.locale.languageCode);
  }
}

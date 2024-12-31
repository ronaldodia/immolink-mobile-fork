import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'dart:convert';

import 'package:immolink_mobile/utils/config.dart';

class DistrictController extends GetxController {
  var districts = [].obs;
  var isLoading = true.obs;
  var selectedDistrict = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final LanguageController language = Get.find(); // Valeur par défaut 'en' si la langue n'est pas trouvée
    fetchDistricts(language.locale.languageCode);
  }

  // Fonction pour récupérer les catégories
  Future<void> fetchDistricts(String language) async {
    try {
      isLoading(true);
      print('${Config.initUrl}/api/districts?language=$language');
      final response = await http.get(Uri.parse('${Config.initUrl}/api/districts?language=$language'));
      print(response.body);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // print(data[0]['data']);
        districts.value = data['data'];
      } else {
        // En cas d'erreur
        Get.snackbar("Error", "Failed to fetch districts");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch districts: $e");
    } finally {
      isLoading(false);
    }
  }
}
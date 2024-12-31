import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'dart:convert';

import 'package:immolink_mobile/models/Commune.dart';
import 'package:immolink_mobile/utils/config.dart';

class CommuneController extends GetxController {
  var communes = <Commune>[].obs;
  var selectedCommune = Rxn<Commune>();
  var selectedDistrict = Rxn<District>();

  @override
  void onInit() {
    super.onInit();
    final LanguageController language = Get.find();
    fetchCommunes(language.locale.languageCode);
    // Sélectionnez automatiquement la première commune si disponible
    if (communes.isNotEmpty) {
      selectedCommune.value = communes.first;
    }
  }

  Future<void> fetchCommunes(String language) async {
    try {
      final response = await http.get(Uri.parse(
          '${Config.baseUrlApp}/communes?language=$language'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body) as List;
        communes.value =
            data.map((commune) => Commune.fromJson(commune)).toList();
      } else {
        Get.snackbar("Erreur", "Impossible de récupérer les données");
      }
    } catch (e) {
      Get.snackbar("Erreur", e.toString());
    }
  }
}

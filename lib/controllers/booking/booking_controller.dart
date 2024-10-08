import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:immolink_mobile/utils/config.dart';

class BookingController extends GetxController {
  var reservedDates = <DateTime>[].obs;
  var isLoading = true.obs;

  // Méthode pour récupérer les dates réservées d'un article en passant l'ID
  Future<void> fetchReservedDates(int articleId) async {
    final url = '${Config.baseUrlApp}/bookings/reserved_dates/$articleId'; // Utilisation de l'ID dans l'URL

    try {
      isLoading.value = true;  // On commence par indiquer que le chargement est en cours
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Décodage de l'objet JSON
        var data = jsonDecode(response.body);

        // Extraction de la liste des dates à partir de l'objet JSON
        List<dynamic> reservedDatesData = data['reserved_dates'];

        // Conversion des dates en objets DateTime
        reservedDates.value = reservedDatesData.map((date) => DateTime.parse(date)).toList();
      } else {
        Get.snackbar(
          'Erreur',
          'Impossible de récupérer les dates réservées 😕',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la récupération des dates.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;  // Le chargement est terminé
    }
  }
}

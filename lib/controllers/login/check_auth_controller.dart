import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:immolink_mobile/utils/config.dart';

class CheckAuthController extends GetxController {
  static CheckAuthController get instance => Get.find();
  final localStorage = GetStorage();

  // Méthode pour vérifier le token
  Future<bool> checkToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrlApp}/check-token'), // Remplace par ton URL
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print("La Reponse: $jsonResponse");

        return jsonResponse['status'] == 'valid';
      }
      else {
        return true;
      }
    } catch (e) {
      print('Erreur lors de la vérification du token : $e');
      return true;
    }
  }

  Future<bool> checkUserToken() async {
    try {
      // Récupération du token
      final String? token = await localStorage.read('AUTH_TOKEN');
      print('Token récupéré : $token');

      // Vérification si le token existe
      if (token == null) {
        print("Aucun token trouvé.");
        return false;
      }

      // Appel de l'API pour valider le token
      final response = await checkToken(token);
      print("Check Token $response");

      // Vérification de la réponse
      if (response) {
        print("Le token est valide.");
        return true;
      } else {
        // Token invalide : suppression et redirection (si nécessaire)
        print("Token invalide. Suppression du token...");
        localStorage.remove('AUTH_TOKEN');
        return false;
      }
    } catch (e) {
      // Gestion des erreurs inattendues
      print("Erreur lors de la vérification du token : $e");
      return false;
    }
  }

}
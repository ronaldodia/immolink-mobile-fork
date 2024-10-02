import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:immolink_mobile/models/Article.dart';
import 'dart:convert';  // Assurez-vous d'importer le modèle Article
import 'package:immolink_mobile/utils/config.dart';

class SearchAppController extends GetxController {
  var query = ''.obs;
  var isLoading = false.obs;
  var searchResults = <Article>[].obs;  // Liste de résultats d'articles
  var errorMessage = ''.obs;

  // Méthode pour effectuer une recherche
  Future<void> search(String query) async {
    if (query.length < 3) {
      searchResults.clear();  // Ne rien afficher si la recherche a moins de 3 caractères
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await http.get(Uri.parse('${Config.baseUrlApp}/home/search?name=$query'));

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var data = jsonResponse[0]['data'] as List;

        // Conversion de la liste de JSON en une liste d'objets Article
        searchResults.value = data.map((item) => Article.fromJson(item)).toList();
      } else {
        errorMessage.value = 'Erreur lors de la récupération des données';
      }
    } catch (e) {
      errorMessage.value = 'Erreur de connexion : $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Méthode pour mettre à jour la requête
  void updateQuery(String newQuery) {
    query.value = newQuery;
    search(newQuery);
  }
}

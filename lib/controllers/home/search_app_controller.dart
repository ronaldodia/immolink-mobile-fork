import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:immolink_mobile/models/Article.dart';
import 'dart:convert'; // Assurez-vous d'importer le modèle Article
import 'package:immolink_mobile/utils/config.dart';

class SearchAppController extends GetxController {
  var query = ''.obs;
  var isLoading = false.obs;
  var searchResults = <Article>[].obs; // Liste de résultats d'articles
  var errorMessage = ''.obs;

  // Méthode pour effectuer une recherche
  Future<void> search(String query) async {
    if (query.length < 3) {
      searchResults
          .clear(); // Ne rien afficher si la recherche a moins de 3 caractères
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('Recherche en cours pour: $query');
      final response = await http.get(
        Uri.parse('${Config.baseUrlApp}/home/search?name=$query'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Statut de la réponse: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          var data = jsonResponse[0]['data'] as List;
          print('Nombre de résultats trouvés: ${data.length}');

          searchResults.value =
              data.map((item) => Article.fromJson(item)).toList();
          print('Résultats convertis: ${searchResults.length} articles');
        } else {
          print('Aucun résultat trouvé dans la réponse');
          searchResults.clear();
        }
      } else {
        print('Erreur HTTP: ${response.statusCode}');
        errorMessage.value = 'Erreur lors de la récupération des données';
        searchResults.clear();
      }
    } catch (e) {
      print('Exception lors de la recherche: $e');
      errorMessage.value = 'Erreur de connexion : $e';
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Méthode pour mettre à jour la requête
  void updateQuery(String newQuery) {
    print('Mise à jour de la requête: $newQuery');
    query.value = newQuery;
    search(newQuery);
  }
}

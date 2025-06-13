import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:immolink_mobile/models/Article.dart';
import 'package:immolink_mobile/models/ArticlePromotion.dart';
import 'package:immolink_mobile/utils/config.dart';

class ArticlePromotionController extends GetxController {
  var promotionProperties = <ArticlePromotion>[].obs;
  var featuredProperties = <Article>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPromotionProperties();
    fetchFeaturedProperties();
  }

  Future<void> fetchPromotionProperties() async {
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse('${Config.baseUrlApp}/home/promotion_properties'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Réponse brute de l\'API: ${response.body}');
        final jsonData = jsonDecode(response.body);
        print('Données JSON décodées: $jsonData');

        List<dynamic> articlesData = [];

        // Vérifier si la réponse est un tableau
        if (jsonData is List && jsonData.isNotEmpty) {
          print('La réponse est un tableau avec ${jsonData.length} éléments');
          // Prendre le premier élément qui contient les données paginées
          final paginatedData = jsonData[0];
          print('Données paginées: $paginatedData');

          if (paginatedData is Map && paginatedData.containsKey('data')) {
            articlesData = paginatedData['data'] as List<dynamic>;
            print(
                '${articlesData.length} articles trouvés dans la réponse paginée');
            print(
                'Premier article: ${articlesData.isNotEmpty ? articlesData[0] : 'aucun'}');
          } else {
            print('Les données paginées ne contiennent pas de clé \'data\'');
          }
        } else {
          print('La réponse n\'est pas un tableau ou est vide');
        }

        // Traiter chaque article
        final properties = <ArticlePromotion>[];

        print('Nombre d\'articles à traiter: ${articlesData.length}');

        for (var item in articlesData) {
          try {
            print('\n=== Début du traitement d\'un article ===');
            print('Données brutes de l\'article: $item');

            // Vérifier la structure de l'article
            if (item is! Map<String, dynamic>) {
              print('Erreur: L\'article n\'est pas un Map');
              continue;
            }

            // Vérifier si l'article a les données nécessaires
            if (!item.containsKey('article') || item['article'] == null) {
              print('Article sans données d\'article associées');
              continue;
            }

            print('Données de l\'article: ${item['article']}');

            // Créer l'objet ArticlePromotion
            final articlePromo = ArticlePromotion.fromJson(item);

            // Vérifier si l'article a été correctement créé
            if (articlePromo.article != null) {
              properties.add(articlePromo);
              print(
                  'Article ajouté à la liste des propriétés: ${articlePromo.id}');
              print(
                  'Titre de l\'article: ${articlePromo.article?.getPropertyByLanguage("fr", propertyType: "name")}');
            } else {
              print('Article sans données valides: $item');
            }

            print('=== Fin du traitement de l\'article ===\n');
          } catch (e, stackTrace) {
            print('Erreur lors du traitement d\'un article: $e');
            print('Stack trace: $stackTrace');
            // Continuer avec les articles suivants même si un échoue
          }
        }

        if (properties.isNotEmpty) {
          promotionProperties.value = properties;
          print('${properties.length} articles chargés avec succès');
        } else {
          print('Aucun article valide trouvé dans la réponse');
          promotionProperties.clear();
        }
      } else {
        print('Erreur HTTP: ${response.statusCode}');
        print('Corps de la réponse: ${response.body}');
        throw Exception('Échec du chargement des propriétés promotionnelles');
      }
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print('Exception: $e');
        print('Stacktrace: $stacktrace');
      }
      Get.snackbar("Error", "Failed to load promotion properties");
    } finally {
      isLoading(false);
    }
  }

  void fetchFeaturedProperties() async {
    try {
      isLoading(true);
      final response = await http
          .get(Uri.parse('${Config.baseUrlApp}/home/featured_properties'));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        print(jsonData[0]);
        var article = (jsonData[0] as List)
            .map((item) => Article.fromJson(item))
            .toList();
        featuredProperties.addAll(article);
      }
    } catch (e, stackTrace) {
      // En cas d'erreur
      print(stackTrace);
      Get.snackbar("Error", "$e", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }
}

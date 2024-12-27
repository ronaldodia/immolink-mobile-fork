import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:immolink_mobile/models/Article.dart';
import 'dart:convert';

import 'package:immolink_mobile/utils/config.dart';

class ArticlesController extends GetxController {
  final RxList<Article> articles = <Article>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final int _perPage = 10; // Nombre d'articles par page
  int _currentPage = 1;

  final int perPage = 10; // Nombre d'articles par page

  @override
  void onInit() {
    super.onInit();
    fetchArticles(); // Charger les premiers articles
  }

  Future<void> fetchArticles() async {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;
    final localStorage = GetStorage();
    final String? token = localStorage.read('AUTH_TOKEN');

    try {
      final response = await http.get(
        Uri.parse("${Config.baseUrlApp}/my_articles?page=$_currentPage&per_page=$_perPage"),
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Données reçues : ${data['data']}');

        if (data['data'] != null && data['data'] is List) {
          final List<Article> fetchedArticles = (data['data'] as List)
              .map((item) {
            if (item is Map<String, dynamic>) {
              return Article.fromJson(item);
            } else {
              throw Exception("Format inattendu pour un article : $item");
            }
          })
              .toList();

          if (fetchedArticles.length < _perPage) {
            hasMore.value = false;
          }
          articles.addAll(fetchedArticles);
          _currentPage++;
        } else {
          hasMore.value = false;
          print("Aucune donnée ou format incorrect.");
        }
      } else {
        print("Erreur API : ${response.statusCode}");
        hasMore.value = false;
      }
    } catch (e) {
      print("Erreur lors de la récupération des articles : $e");
    } finally {
      isLoading.value = false;
    }
  }

}

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
  var error = ''.obs;
  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    if (!_isInitialized) {
      _isInitialized = true;
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    try {
      await Future.wait([
        fetchPromotionProperties(),
        fetchFeaturedProperties(),
      ]);
    } catch (e) {
      _showError("Une erreur est survenue lors du chargement des données");
    }
  }

  void _showError(String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Future.microtask(() {
      Get.snackbar(
        "Error",
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    });
  }

  Future<void> fetchPromotionProperties() async {
    try {
      isLoading(true);
      error.value = '';

      final response = await http.get(
        Uri.parse('${Config.baseUrlApp}/home/promotion_properties'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<dynamic> articlesData = [];

        if (jsonData is List && jsonData.isNotEmpty) {
          final paginatedData = jsonData[0];
          if (paginatedData is Map && paginatedData.containsKey('data')) {
            articlesData = paginatedData['data'] as List<dynamic>;
          }
        }

        final properties = <ArticlePromotion>[];
        for (var item in articlesData) {
          try {
            if (item is! Map<String, dynamic> ||
                !item.containsKey('article') ||
                item['article'] == null) {
              continue;
            }

            final articlePromo = ArticlePromotion.fromJson(item);
            if (articlePromo.article != null) {
              properties.add(articlePromo);
            }
          } catch (e, s) {
            print(s);
            print('Erreur lors du traitement d\'un article: $e');
          }
        }

        promotionProperties.value = properties;
      } else {
        throw Exception('Échec du chargement des propriétés promotionnelles');
      }
    } catch (e) {
      error.value = e.toString();
      _showError("Échec du chargement des propriétés promotionnelles");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchFeaturedProperties() async {
    try {
      isLoading(true);
      error.value = '';

      final response = await http.get(
        Uri.parse('${Config.baseUrlApp}/home/featured_properties'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List && jsonData.isNotEmpty && jsonData[0] is List) {
          final articles = (jsonData[0] as List)
              .map((item) => Article.fromJson(item))
              .where((article) => article != null)
              .toList();
          featuredProperties.value = articles;
        } else {
          featuredProperties.clear();
        }
      } else {
        throw Exception('Échec du chargement des propriétés en vedette');
      }
    } catch (e) {
      error.value = e.toString();
      _showError("Échec du chargement des propriétés en vedette");
    } finally {
      isLoading(false);
    }
  }
}

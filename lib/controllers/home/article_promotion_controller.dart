import 'dart:convert';

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

  void fetchPromotionProperties() async {
    try {
      isLoading(true);
      final response = await http.get(Uri.parse('${Config.baseUrlApp}/home/promotion_properties'));

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print('Promote ==========${jsonData[0]['data']}');
        var properties = (jsonData[0]['data'] as List)
            .map((item) => ArticlePromotion.fromJson(item))
            .toList();
        promotionProperties.addAll(properties);
      }
    } catch (e, stacktrace) {
      print('Exception: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
      // En cas d'erreur
      Get.snackbar("Error", "$e");
    } finally {
      isLoading(false);
    }
  }

  void fetchFeaturedProperties() async {
    try {
      isLoading(true);
      final response = await http.get(Uri.parse('${Config.baseUrlApp}/home/featured_properties'));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        print(jsonData[0]);
        var article = (jsonData[0] as List)
            .map((item) => Article.fromJson(item))
            .toList();
        featuredProperties.addAll(article);
      }
    } catch (e) {
      // En cas d'erreur
      print(e);
      Get.snackbar("Error", "$e");
    }finally {
      isLoading(false);
    }
  }
}

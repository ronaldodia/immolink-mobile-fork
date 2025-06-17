// Fichier de correctif pour la navigation des propriétés

import 'package:get/get.dart';
import 'package:immolink_mobile/models/Article.dart';
import 'package:immolink_mobile/views/screens/article/promote_article_details_screen.dart';

/// Navigue vers l'écran de détails approprié pour une propriété donnée
/// 
/// Cette fonction unifie la navigation pour toutes les propriétés, en s'assurant
/// que toutes les propriétés utilisent le même écran de détails (PromoteArticleDetailsScreen)
/// au lieu d'utiliser FeaturedPropertyCard pour certaines catégories.
void navigateToPropertyDetails(Article article) {
  // Toujours naviguer vers PromoteArticleDetailsScreen pour toutes les propriétés
  Get.to(() => PromoteArticleDetailsScreen(property: article));
}

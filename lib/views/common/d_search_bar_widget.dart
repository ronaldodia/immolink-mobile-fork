import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/home/search_app_controller.dart';
import 'package:immolink_mobile/models/Article.dart';
import 'package:immolink_mobile/views/screens/article/futuread_article_details_screen.dart';
import 'package:immolink_mobile/views/screens/article/promote_article_details_screen.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.text,
    this.icon = Icons.search,
    this.showBackground = true,
    this.showBorder = true,
    this.secondIcon = Icons.tune,
  });

  final String text;
  final IconData? icon, secondIcon;
  final bool showBackground, showBorder;

  @override
  Widget build(BuildContext context) {
    final SearchAppController searchController = Get.put(SearchAppController());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: showBackground ? Colors.transparent : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: showBorder ? Border.all(color: Colors.grey) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      icon: Icon(icon, color: Colors.grey),
                      hintText: text,
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      searchController.updateQuery(value);
                    },
                  ),
                ),
                Icon(secondIcon, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (searchController.query.value.isEmpty) {
              return Container();  // Pas de liste si l'utilisateur n'a rien tapé
            } else if (searchController.isLoading.value) {
              return const CircularProgressIndicator();  // Loader pendant la recherche
            } else if (searchController.searchResults.isEmpty) {
              return const Text('Aucun résultat trouvé');  // Message en cas d'absence de résultats
            } else {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),  // Empêche le scroll interne
                itemCount: searchController.searchResults.length,
                itemBuilder: (context, index) {
                  final Article article = searchController.searchResults[index];

                  return ListTile(
                    leading: Image.network(article.image, width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(article.name ?? 'Sans titre'),  // Protection contre les valeurs nulles
                    subtitle: Text(article.purpose),
                    onTap: () async {
                      if (article.id != null) {
                        // Affiche un dialogue de chargement
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );
                        // Attendre quelques secondes pour simuler un chargement
                        await Future.delayed(const Duration(seconds: 2));
                        // Fermer le dialogue de chargement
                        Navigator.pop(context);
                        // Navigation vers la page de détails
                        Get.to(PromoteArticleDetailsScreen(property: article));
                      }
                    },
                  );
                },
              );
            }
          }),
        ],
      ),
    );
  }
}

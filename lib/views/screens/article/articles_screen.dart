import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/articles/article_controller.dart';
import 'package:immolink_mobile/controllers/login/check_auth_controller.dart';
import 'package:immolink_mobile/models/Article.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/views/screens/article/create_article_screen.dart';
import 'package:immolink_mobile/views/screens/login_email_screen.dart';

import '../../common/d_search_bar_widget.dart';

class ArticlesScreen extends StatelessWidget {
  ArticlesScreen({super.key});

  final ArticlesController controller = Get.put(ArticlesController());

  @override
  Widget build(BuildContext context) {
    final CheckAuthController authController = Get.find();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Barre de recherche
          const SearchBarWidget(
            text: 'Rechercher...',
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.articles.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                itemCount: controller.articles.length + 1, // +1 pour le loader de fin
                itemBuilder: (context, index) {
                  if (index < controller.articles.length) {
                    final Article article = controller.articles[index];
                    return ListTile(
                      leading: Image.network(
                        article.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                      ),
                      title: Text(article.name ?? "Nom non spécifié"),
                      subtitle: Text("Prix : ${article.price}"),
                      onTap: () {
                        // Logique pour ouvrir les détails de l'article
                      },
                    );
                  } else if (controller.hasMore.value) {
                    controller.fetchArticles(); // Charger plus d'articles
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return const Center(child: Text("Aucun article supplémentaire"));
                  }
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool isAuthenticated = await authController.checkUserToken();
          if (isAuthenticated) {
            Get.to(() =>  CreateArticleScreen());
          } else {
            Get.to(() => const LoginEmailScreen());
          }
        },
        backgroundColor: Colors.teal,
        child: SvgPicture.asset(
          TImages.add,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }
}

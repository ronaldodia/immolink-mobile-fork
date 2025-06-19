import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:immolink_mobile/controllers/currency/currency_controller.dart';
import 'package:immolink_mobile/controllers/home/article_promotion_controller.dart';
import 'package:immolink_mobile/utils/navigation_fix.dart';

class AllPropertiesScreen extends StatelessWidget {
  const AllPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ArticlePromotionController articlePromotionController = Get.find();
    final CurrencyController currencyController = Get.find();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Toutes les annonces',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (articlePromotionController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (articlePromotionController.featuredProperties.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Aucune propriété disponible',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: articlePromotionController.featuredProperties.length,
          itemBuilder: (context, index) {
            final article =
                articlePromotionController.featuredProperties[index];
            final status = article.status.toLowerCase();

            // Construction de l'URL de l'image
            String imageUrl = '';
            if (article.gallery.isNotEmpty) {
              final galleryItem = article.gallery.first;
              imageUrl = galleryItem.original;
            } else if (article.image.isNotEmpty) {
              imageUrl = article.image;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  navigateToPropertyDetails(article);
                },
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image à gauche
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          bottomLeft: Radius.circular(12.0),
                        ),
                        child: Image.network(
                          imageUrl,
                          width: 110.0,
                          height: 110.0,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 110.0,
                            height: 110.0,
                            color: Colors.grey[100],
                            child: const Icon(Icons.photo_library_outlined,
                                color: Colors.grey, size: 32.0),
                          ),
                        ),
                      ),
                      // Détails à droite
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Catégorie et prix
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Badge de catégorie
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6.0, vertical: 2.0),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(4.0),
                                      border: Border.all(
                                        color: Colors.blue[100]!,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (article
                                                .category?.image?.isNotEmpty ??
                                            false)
                                          SvgPicture.network(
                                            article.category!.image!,
                                            height: 12,
                                            width: 12,
                                            colorFilter: ColorFilter.mode(
                                                Colors.blue[800]!,
                                                BlendMode.srcIn),
                                          ),
                                        if (article
                                                .category?.image?.isNotEmpty ??
                                            false)
                                          const SizedBox(width: 4),
                                        Text(
                                          article.category?.name ?? 'Catégorie',
                                          style: TextStyle(
                                            color: Colors.blue[800],
                                            fontSize: 9.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Prix
                                  Flexible(
                                    child: Text(
                                      currencyController
                                          .formatPrice(article.price),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                        fontSize: 13.0,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6.0),
                              // Nom de la propriété
                              Text(
                                article.getPropertyByLanguage(
                                    Get.locale?.languageCode ?? 'fr',
                                    propertyType: "name"),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.0,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2.0),
                              // Localisation
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      size: 11.0, color: Colors.grey[400]),
                                  const SizedBox(width: 2.0),
                                  Expanded(
                                    child: Text(
                                      article.structure?.name ??
                                          'Localisation non disponible',
                                      style: TextStyle(
                                        fontSize: 10.0,
                                        color: Colors.grey[600],
                                        height: 1.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              // Caractéristiques
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildAmenity(Icons.king_bed_outlined,
                                      '${article.bedroom ?? 0}'),
                                  const SizedBox(width: 4.0),
                                  _buildAmenity(Icons.bathtub_outlined,
                                      '${article.bathroom ?? 0}'),
                                  const Spacer(),
                                  if (![
                                    'apartment',
                                    'hostel',
                                    'office',
                                    'store'
                                  ].contains(article.category?.slug))
                                    _buildAmenity(Icons.square_foot,
                                        '${article.area?.toInt() ?? 0} m²'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildAmenity(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.0, color: Colors.grey[600]),
        const SizedBox(width: 4.0),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}



import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/currency/currency_controller.dart';
import 'package:immolink_mobile/models/Article.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/views/screens/article/common/gallery_panel.dart';

class FutureadArticleDetailsScreen extends StatelessWidget {
  const FutureadArticleDetailsScreen({super.key, required this.property});
  final Article property;

  @override
  Widget build(BuildContext context) {
    final CurrencyController currencyController = Get.find();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(property.name ?? 'Property Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Fonctionnalité de partage
              print("Share button tapped");
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image principale avec badge "Featured" et bouton favoris
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      property.image ?? 'default_image.png',
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  left: 15,
                  top: 15,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.orange,
                    child: const Text(
                      'Featured',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      // Ajouter aux favoris
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Galerie d'images
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: property.gallery.length,
                itemBuilder: (context, index) {
                  final image = property.gallery[index];
                  return GestureDetector(
                    onTap: () {
                      // Ouvrir panel de visualisation de la galerie
                      _showGalleryPanel(context, property.gallery, index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: FadeInImage(
                          placeholder: AssetImage('assets/images/loading_placeholder.png'), // Image de chargement local
                          image: NetworkImage('${Config.initUrl}${image.original}'),
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image, size: 50, color: Colors.red);
                          },
                          fadeInDuration: Duration(milliseconds: 300), // Animation de fade-in
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Informations sur la propriété
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // Icone et catégorie
                  Row(
                    children: [
                      SvgPicture.network(
                          property.category!.image! ?? '',
                          height: 40,
                          width: 40,
                          colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn)
                      ),
                      const SizedBox(width: 8),
                      Text(property.category!.name ?? 'Category'),
                    ],
                  ),
                  const Spacer(),
                  // Badge "Purpose"
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.blue,
                    child: Text(
                      property.purpose,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Nom et prix
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name ?? 'Unknown Property',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Price
                  Obx(() {
                    double convertedPrice = property.price *
                        currencyController.selectedCurrency.value.exchangeRate;
                    return Text(
                      "${convertedPrice.toStringAsFixed(2)} ${currencyController.selectedCurrency.value.symbol}",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .apply(color: Colors.green, fontWeightDelta: 2),
                    );
                  }),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8.0),
              child: Wrap(
                spacing: 16.0, // Espace horizontal entre les éléments
                runSpacing: 16.0, // Espace vertical entre les lignes
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAmenity(
                        icon: TImages.bedroom,
                        label: 'Bedroom',
                        value: property.bedroom ?? 0,
                      ),
                      _buildAmenity(
                        icon: TImages.bathroom,
                        label: 'Bathroom',
                        value: property.bathroom,
                      ),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAmenity(
                          icon: TImages.area,
                          label: 'Area',
                          value: '${property.area} m²',
                        ),
                        _buildAmenity(
                          icon: TImages.balcony,
                          label: 'Balcony',
                          value: property.balcony,
                        ),
                      ]),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAmenity({required String icon, required String label, required dynamic value}) {
    return Row(
      children: [ // Si l'icône est un chemin de fichier SVG
        SvgPicture.asset(
          icon,
          height: 40,
          width: 40,
          // colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn)
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }


  void _showGalleryPanel(BuildContext context, List gallery, int initialIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GalleryPanel(gallery: gallery, initialIndex: initialIndex);
      },
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:immolink_mobile/controllers/chat/chat_controller.dart';
import 'package:immolink_mobile/controllers/currency/currency_controller.dart';
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'package:immolink_mobile/controllers/login/check_auth_controller.dart';
import 'package:immolink_mobile/models/Article.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/views/screens/article/common/gallery_panel.dart';
import 'package:immolink_mobile/views/screens/article/promote_article_details_screen.dart';
import 'package:immolink_mobile/views/screens/booking_screen.dart';
import 'package:immolink_mobile/views/screens/chat_screen.dart';
import 'package:immolink_mobile/views/screens/login_phone_screen.dart';

class FutureadArticleDetailsScreen extends StatefulWidget {
  const FutureadArticleDetailsScreen({super.key, required this.property});

  final Article property;

  @override
  State<FutureadArticleDetailsScreen> createState() =>
      _FutureadArticleDetailsScreenState();
}

class _FutureadArticleDetailsScreenState
    extends State<FutureadArticleDetailsScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.put(ChatController());
    final CheckAuthController authController = Get.put(CheckAuthController());
    final CurrencyController currencyController = Get.find();
    final LanguageController languageController = Get.find();
    bool isLocationAvailable = widget.property.location_latitude! != null &&
        widget.property.location_latitude!.isNotEmpty &&
        widget.property.location_longitude != null &&
        widget.property.location_longitude!.isNotEmpty;
    final agentId = widget.property.structure != null
        ? widget.property.structure!.owner_id
        : widget.property.author_id;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(widget.property.getPropertyByLanguage(
                languageController.locale.languageCode,
                propertyType: "name") ??
            'Property Details'),
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
                      widget.property.image ?? 'default_image.png',
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
                itemCount: widget.property.gallery.length,
                itemBuilder: (context, index) {
                  final image = widget.property.gallery[index];
                  return GestureDetector(
                    onTap: () {
                      // Ouvrir panel de visualisation de la galerie
                      _showGalleryPanel(
                          context, widget.property.gallery, index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: FadeInImage(
                          placeholder: const AssetImage(
                              'assets/images/loading_placeholder.png'),
                          // Image de chargement local
                          image: NetworkImage(
                              '${Config.initUrl}${image.original}'),
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image,
                                size: 50, color: Colors.red);
                          },
                          fadeInDuration: const Duration(
                              milliseconds: 300), // Animation de fade-in
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
                      SvgPicture.network(widget.property.category!.image! ?? '',
                          height: 40,
                          width: 40,
                          colorFilter: const ColorFilter.mode(
                              Colors.green, BlendMode.srcIn)),
                      const SizedBox(width: 8),
                      Text(widget.property.category!
                              .getName(Get.locale?.languageCode ?? 'fr') ??
                          'Category'),
                    ],
                  ),
                  const Spacer(),
                  // Badge "Purpose"
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.blue,
                    child: Text(
                      widget.property.purpose ?? '',
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
                    widget.property.getPropertyByLanguage(
                            languageController.locale.languageCode,
                            propertyType: "name") ??
                        'Unknown Property',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Price
                  Obx(() {
                    double convertedPrice =
                        currencyController.convertPrice(widget.property.price);
                    return Text(
                      "${convertedPrice.toStringAsFixed(2)} ${currencyController.getCurrentSymbol()}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 13.0,
                      ),
                    );
                  }),
                ],
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                        value: widget.property.bedroom ?? 0,
                      ),
                      _buildAmenity(
                        icon: TImages.bathroom,
                        label: 'Bathroom',
                        value: widget.property.bathroom,
                      ),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAmenity(
                          icon: TImages.area,
                          label: 'Area',
                          value: '${widget.property.area} m²',
                        ),
                        _buildAmenity(
                          icon: TImages.balcony,
                          label: 'Balcony',
                          value: widget.property.balcony,
                        ),
                      ]),
                ],
              ),
            ),

            // Property Description Section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Affiche le texte avec une limite de lignes si non expansé
                  Text(
                    widget.property.getPropertyByLanguage(
                            languageController.locale.languageCode,
                            propertyType: "description") ??
                        'No description available.',
                    maxLines: _isExpanded
                        ? null
                        : 5, // Limite à 5 lignes si non expansé
                    overflow: _isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),

                  // Bouton "Voir plus" ou "Voir moins"
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded =
                            !_isExpanded; // Alterne entre expansion et rétrécissement
                      });
                    },
                    child: Text(
                      _isExpanded ? "Voir moins" : "Voir plus",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Section de la petite carte
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: isLocationAvailable
                  ? GestureDetector(
                      onTap: () {
                        // Lorsque l'utilisateur tape sur la carte, il est redirigé vers la carte en plein écran
                        Get.to(FullMapScreen(
                            latitude: double.parse(
                                widget.property.location_latitude!),
                            longitude: double.parse(
                                widget.property.location_longitude!)));
                      },
                      child: Container(
                        height: 150, // Petite section pour la carte
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target:
                                LatLng(18.110686245353225, -15.998744332959172),
                            zoom: 14.0,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('propertyLocation'),
                              position: LatLng(
                                  double.parse(
                                      widget.property.location_latitude ?? ''),
                                  double.parse(
                                      widget.property.location_longitude ??
                                          '')),
                            ),
                          },
                          zoomControlsEnabled: false,
                          // mapType: MapType.satellite,
                          scrollGesturesEnabled: false,
                          tiltGesturesEnabled: false,
                          rotateGesturesEnabled: false,
                          onTap: (LatLng position) {
                            Get.to(FullMapScreen(
                                latitude: double.parse(
                                    widget.property.location_latitude!),
                                longitude: double.parse(
                                    widget.property.location_longitude!)));
                          },
                        ),
                      ),
                    )
                  : const Center(
                      child: Text(
                        'Position non disponible',
                      ),
                    ),
            )
          ],
        ),
      ),
      bottomNavigationBar: widget.property.purpose == "Rent"
          ? Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              color: Colors.white,
              child: ElevatedButton(
                onPressed: () async {
                  // Vérifier si l'utilisateur est connecté via Firebase
                  User? user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    // Si l'utilisateur est connecté, naviguer vers la page de réservation
                    Get.to(() => BookingScreen(
                          articleId: widget.property.id,
                          eventType: 'Mariage', // Par exemple, pour Mariage
                        ));
                  } else {
                    // Sinon, naviguer vers la page de connexion et sauvegarder l'intention
                    Get.to(() => const LoginPhoneScreen(), arguments: {
                      'nextPage': BookingScreen(
                        articleId: widget.property.id,
                        eventType: 'Mariage',
                      )
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Réservez Maintenant!',
                    style:  TextStyle(fontSize: 20, color: Colors.white)),
              ),
            )
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  final CheckAuthController authController =
                      Get.put(CheckAuthController());
                  bool isAuthenticated = await authController.checkUserToken();
                  User? user = FirebaseAuth.instance.currentUser;

                  print(isAuthenticated);
                  final conversation =
                      await chatController.getOrCreateConversation(
                    propertyId: widget.property.id,
                    propertyTitle: widget.property.getPropertyByLanguage(
                            languageController.locale.languageCode,
                            propertyType: "name") ??
                        'Property Chat',
                    agentId: agentId,
                  );

                  if (isAuthenticated) {
                    Get.to(ChatScreen(
                        conversationId: conversation.id, agentId: agentId));
                  } else if (user != null) {
                    Get.to(ChatScreen(
                        conversationId: conversation.id, agentId: agentId));
                  } else {
                    Get.to(() => const LoginPhoneScreen(), arguments: {
                      'nextPage': ChatScreen(
                        conversationId: conversation.id,
                      )
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Discutez',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      TImages.inactiveChat,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAmenity(
      {required String icon, required String label, required dynamic value}) {
    return Row(
      children: [
        // Si l'icône est un chemin de fichier SVG
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

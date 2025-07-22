import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:immolink_mobile/controllers/chat/chat_controller.dart';
import 'package:immolink_mobile/controllers/currency/currency_controller.dart';
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'package:immolink_mobile/controllers/login/check_auth_controller.dart';
import 'package:immolink_mobile/models/Article.dart';
import 'package:immolink_mobile/views/screens/article/common/gallery_panel.dart';
import 'package:immolink_mobile/views/screens/booking_screen.dart';
import 'package:immolink_mobile/views/screens/chat_screen.dart';
import 'package:immolink_mobile/views/screens/login_phone_screen.dart';
import 'package:immolink_mobile/utils/config.dart';

import '../../../utils/image_constants.dart';

class PromoteArticleDetailsScreen extends StatefulWidget {
  const PromoteArticleDetailsScreen({super.key, required this.property});
  final Article property;

  @override
  State<PromoteArticleDetailsScreen> createState() =>
      _PromoteArticleDetailsScreenState();
}

class _PromoteArticleDetailsScreenState
    extends State<PromoteArticleDetailsScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final CheckAuthController authController = Get.put(CheckAuthController());
    final localStorage = GetStorage();
    bool isLocationAvailable = widget.property.location_latitude != null &&
        widget.property.location_latitude!.isNotEmpty &&
        widget.property.location_longitude != null &&
        widget.property.location_longitude!.isNotEmpty;
    final CurrencyController currencyController = Get.find();
    final LanguageController languageController = Get.find();

    // Construction de l'URL de l'image
    String imageUrl = '';
    if (widget.property.gallery.isNotEmpty) {
      final galleryItem = widget.property.gallery.first;
      imageUrl = galleryItem.original;
    } else if (widget.property.image.isNotEmpty) {
      imageUrl = widget.property.image;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.property.getPropertyByLanguage(
                  languageController.locale.languageCode,
                  propertyType: "name") ??
              'Property Details',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black87),
            onPressed: () async {
              String? token = await localStorage.read('AUTH_TOKEN');
              print(token);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image principale avec badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24.0),
                    bottomRight: Radius.circular(24.0),
                  ),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 300,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue[400]!),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 300,
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.photo_library_outlined,
                                      size: 40.0, color: Colors.grey),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'Image non disponible',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 300,
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.photo_library_outlined,
                                  size: 40.0, color: Colors.grey),
                              const SizedBox(height: 8.0),
                              Text(
                                'Aucune image',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                if (widget.property.bookable_type!.contains('Daily'))
                  Positioned(
                    top: 16.0,
                    left: 16.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.amber, Colors.orange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chair_alt,
                            color: Colors.white,
                            size: 14.0,
                          ),
                          SizedBox(width: 4.0),
                          Text(
                            'MEUBLÉ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 16.0,
                  right: 16.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 14.0,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          widget.property.purpose!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Galerie d'images
            if (widget.property.gallery.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: widget.property.gallery.length,
                    itemBuilder: (context, index) {
                      final image = widget.property.gallery[index];
                      return GestureDetector(
                        onTap: () {
                          print(widget.property.gallery);
                          return _showGalleryPanel(
                              context, widget.property.gallery, index);
                        },
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1.0,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.network(
                              image.original,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image,
                                      color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Informations principales
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prix
                  Obx(() {
                    double convertedPrice =
                        currencyController.convertPrice(widget.property.price);
                    return Text(
                      "${convertedPrice.toStringAsFixed(0)} ${currencyController.getCurrentSymbol()}",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    );
                  }),
                  const SizedBox(height: 8.0),

                  // Nom de la propriété
                  Text(
                    widget.property.getPropertyByLanguage(
                            languageController.locale.languageCode,
                            propertyType: "name") ??
                        'Unknown Property',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // Localisation
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 16.0, color: Colors.grey[600]),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          widget.property.structure?.name ??
                              'Localisation non disponible',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Caractéristiques
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFeatureItem(Icons.king_bed_outlined,
                            '${widget.property.bedroom ?? 0}', 'Chambres'),
                        _buildFeatureItem(Icons.bathtub_outlined,
                            '${widget.property.bathroom ?? 0}', 'SDB'),
                        _buildFeatureItem(Icons.square_foot,
                            '${widget.property.area?.toInt() ?? 0}', 'm²'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.property.getPropertyByLanguage(
                        languageController.locale.languageCode,
                        propertyType:
                            "description_${languageController.locale.languageCode}"),
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                    maxLines: _isExpanded ? null : 3,
                    overflow: _isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                  if (widget.property.getPropertyByLanguage(
                              languageController.locale.languageCode,
                              propertyType: "description") !=
                          null &&
                      (widget.property
                                  .getPropertyByLanguage(
                                      languageController.locale.languageCode,
                                      propertyType: "description")
                                  ?.length ??
                              0) >
                          150)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Text(
                        _isExpanded ? 'Voir moins' : 'Voir plus',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Carte
            if (isLocationAvailable)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Localisation',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    GestureDetector(
                      onTap: () {
                        Get.to(FullMapScreen(
                          latitude:
                              double.parse(widget.property.location_latitude!),
                          longitude:
                              double.parse(widget.property.location_longitude!),
                        ));
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                double.parse(
                                    widget.property.location_latitude!),
                                double.parse(
                                    widget.property.location_longitude!),
                              ),
                              zoom: 15.0,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('propertyLocation'),
                                position: LatLng(
                                  double.parse(
                                      widget.property.location_latitude!),
                                  double.parse(
                                      widget.property.location_longitude!),
                                ),
                              ),
                            },
                            zoomControlsEnabled: false,
                            scrollGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                            rotateGesturesEnabled: false,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: widget.property.purpose == "Rent"
          ? Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () async {
            bool isAuthenticated = await authController.checkUserToken();
            if (isAuthenticated) {
              Get.to(() => BookingScreen(
                articleId: widget.property.id,
                eventType: 'Mariage',
              ));
            } else {
              Get.to(() => const LoginPhoneScreen(), arguments: {
                'nextPage': BookingScreen(
                  articleId: widget.property.id,
                  eventType: 'Mariage',
                )
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Réserver maintenant',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      )
          : widget.property.purpose?.toLowerCase() == 'sell'
          ? Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () async {
            final ChatController chatController = Get.put(ChatController());
            final LanguageController languageController = Get.find();
            bool isAuthenticated = await authController.checkUserToken();
            User? user = FirebaseAuth.instance.currentUser;

            final agentId = widget.property.structure != null
                ? widget.property.structure!.owner_id
                : widget.property.author_id;

            final conversation = await chatController.getOrCreateConversation(
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Discutez',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              const SizedBox(width: 8),
              SvgPicture.asset(
                TImages.inactiveChat,
                colorFilter:
                const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ],
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildFeatureItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24.0, color: Colors.blue[700]),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showGalleryPanel(BuildContext context, List gallery, int initialIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GalleryPanel(gallery: gallery, initialIndex: initialIndex);
      },
    );
  }
}

class FullMapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;

  const FullMapScreen(
      {super.key, required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Localisation",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 16.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('propertyLocationFull'),
            position: LatLng(latitude, longitude),
          ),
        },
      ),
    );
  }
}
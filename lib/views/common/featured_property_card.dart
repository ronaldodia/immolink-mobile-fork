import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:immolink_mobile/controllers/currency/currency_controller.dart';

class FeaturedPropertyCard extends StatelessWidget {
  final String? image;
  final String status;
  final bool isFeatured;
  final String? categoryIcon;
  final String categoryName;
  final String name;
  final String location;
  final double price;
  final List<IconData> amenities;
  final void Function()? onTap;

  const FeaturedPropertyCard({
    super.key,
    required this.image,
    required this.status,
    required this.isFeatured,
    required this.categoryIcon,
    required this.categoryName,
    required this.name,
    required this.location,
    required this.price,
    required this.amenities,
    this.onTap,
  });

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sell':
        return 'Vente';
      case 'rent':
        return 'Location';
      case 'daily':
        return 'Journalier';
      default:
        return status;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'sell':
        return Colors.red.withOpacity(0.8);
      case 'rent':
        return Colors.blue.withOpacity(0.8);
      case 'daily':
        return Colors.orange.withOpacity(0.8);
      default:
        return Colors.grey.withOpacity(0.8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CurrencyController currencyController = Get.find();

    return GestureDetector(
      onTap: onTap,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 4)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Image
                    image?.isNotEmpty == true
                        ? Image.network(
                            image!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              TImages.featured1,
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            TImages.featured1,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                    // Gradient overlay
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    // Status badges
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusBackgroundColor(status),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getStatusColor(status).toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: TSizes.spaceBtwItems),
                          // Premium badge
                          if (isFeatured)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Premium',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Category and Price
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Category
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (categoryIcon != null)
                                  SvgPicture.network(
                                    categoryIcon!,
                                    height: 20,
                                    width: 20,
                                    colorFilter: const ColorFilter.mode(
                                        Colors.white, BlendMode.srcIn),
                                  )
                                else
                                  Image.asset(
                                    'assets/images/default_icon.png',
                                    height: 20,
                                    width: 20,
                                    fit: BoxFit.cover,
                                  ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    categoryName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Price
                          // Obx(() {
                          //   // double convertedPrice = price *
                          //   //     currencyController
                          //   //         .selectedCurrency.value.exchangeRate!;
                          //   // return Text(
                          //   //   "${convertedPrice.toStringAsFixed(0)} ${currencyController.selectedCurrency.value.symbol}",
                          //   //   style: const TextStyle(
                          //   //       color: Colors.white,
                          //   //       fontWeight: FontWeight.bold,
                          //   //       fontSize: 16),
                          //   // );
                          // }),
                        ],
                      ),
                    ),
                    // Property Name
                    Positioned(
                      bottom: 48,
                      left: 8,
                      right: 8,
                      child: Text(
                        name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Location
                    Positioned(
                      bottom: 32,
                      left: 8,
                      right: 8,
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              location,
                              style: const TextStyle(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/currency/currency_controller.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';

class PropertyCardWidget extends StatelessWidget {
  final String image;
  final bool isFeatured;
  final String status; // "rent", "sell", etc.
  final String category;
  final double price;
  final String name;
  final String location;
  final IconData? favoriteIcon;
  final void Function()? onFavoriteTap;
  final void Function()? onTap;

  const PropertyCardWidget({
    super.key,
    required this.image,
    required this.isFeatured,
    required this.status,
    required this.category,
    required this.price,
    required this.name,
    required this.location,
    this.onFavoriteTap, this.onTap, this.favoriteIcon = Icons.favorite_border,
  });

  @override
  Widget build(BuildContext context) {
    final CurrencyController currencyController = Get.find();
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Stack(
          children: [
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Row(
                children: [
                  // Image section
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.33,  // 1/3 of the width
                    height: 130,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                          child: Image.asset(
                            image,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: isFeatured
                              ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'FEATURED',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          )
                              : const SizedBox.shrink(),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Details section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category
                          Row(
                            children: [
                              const Icon(Icons.house_outlined, color: Colors.blueGrey,),
                              const SizedBox(width: 8),
                              Text(
                                category,
                                style: Theme.of(context).textTheme.bodySmall!.apply(
                                  color: Colors.blueGrey,
                                  fontWeightDelta: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Price
                          Obx(() {
                            double convertedPrice = price * currencyController.selectedCurrency.value.exchangeRate;
                            return Text(
                              "${convertedPrice.toStringAsFixed(2)} ${currencyController.selectedCurrency.value.symbol}",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .apply(color: Colors.black87, fontWeightDelta: 2),
                            );
                          }),
                          const SizedBox(height: 4),
                          // Name
                          Text(
                            name,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .apply(color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          // Location
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .apply(color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

           isRtl ?
           Positioned(
             top: 8,
             left: 8,
             child: IconButton(
               icon:  Icon(favoriteIcon, color: Colors.red),
               onPressed: onFavoriteTap,
             ),
           )
           :
            // Favorite button in the top right corner
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon:  Icon(favoriteIcon, color: Colors.red),
                onPressed: onFavoriteTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

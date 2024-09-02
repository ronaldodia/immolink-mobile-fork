import 'package:flutter/material.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';

class FeaturedPropertyCard extends StatelessWidget {
  final String image;
  final String status; // "sell", "rent", etc.
  final bool isFeatured; // true or false
  final IconData categoryIcon;
  final String categoryName;
  final String name;
  final String location;  // Emplacement
  final String price;
  final List<IconData> amenities; // List of icons representing amenities
  final void Function()? onTap;

  const FeaturedPropertyCard({
    super.key,
    required this.image,
    required this.status,
    required this.isFeatured,
    required this.categoryIcon,
    required this.categoryName,
    required this.name,
    required this.location,  // Emplacement
    required this.price,
    required this.amenities, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Directionality(
        textDirection: TextDirection.ltr,  // Ici, il s'adaptera automatiquement à la langue du système.
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 300, // Ajustez la largeur selon votre design
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, spreadRadius: 4)],
            ),
            child: Stack(
              children: [
                // Image and details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with overlay
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Image(
                            image: AssetImage(
                              image,
                            ),
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            width: double.infinity,
                            height: 180,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Status (Sell/Rent)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        status.toUpperCase(),
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: TSizes.spaceBtwItems),
                                    // Featured
                                    if (isFeatured)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'FEATURED',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Category Icon and Name with Price
                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Category Icon and Name
                                Row(
                                  children: [
                                    Icon(categoryIcon, color: Colors.white, size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      categoryName,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                // Price
                                Text(
                                  price,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
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
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          // Emplacement
                          Positioned(
                            bottom: 32,
                            left: 8,
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white, size: 20), // Location icon
                                const SizedBox(width: 4),
                                Text(
                                  location,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

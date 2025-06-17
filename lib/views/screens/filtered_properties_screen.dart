import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/articles/filter_controller.dart';
import 'package:immolink_mobile/controllers/currency/currency_controller.dart';
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'package:immolink_mobile/l10n/app_localizations.dart';
import 'package:immolink_mobile/utils/navigation_fix.dart';

class FilteredPropertiesScreen extends StatelessWidget {
  const FilteredPropertiesScreen({super.key});

  String getCategoryName(Map<String, dynamic> property, String language) {
    if (property['categories'] != null) {
      final category = property['categories'];
      switch (language) {
        case 'fr':
          return category['name'] ?? 'Catégorie';
        case 'ar':
          return category['name_ar'] ?? category['name'] ?? 'Catégorie';
        case 'en':
          return category['name_en'] ?? category['name'] ?? 'Catégorie';
        default:
          return category['name'] ?? 'Catégorie';
      }
    }
    return 'Catégorie';
  }

  @override
  Widget build(BuildContext context) {
    final FilterController filterController = Get.find<FilterController>();
    final LanguageController languageController =
        Get.find<LanguageController>();
    final CurrencyController currencyController =
        Get.find<CurrencyController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          l10n.search_results,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: Obx(() {
        if (filterController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (filterController.filteredProperties.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64.0,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16.0),
                Text(
                  l10n.no_properties_found,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    l10n.dont_miss_new_properties,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24.0),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed('/property-alert');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: Text(
                    l10n.create_alert,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    l10n.alert_notification,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: filterController.filteredProperties.length,
          itemBuilder: (context, index) {
            final property = filterController.filteredProperties[index];
            String imageUrl = '';
            if (property['gallery'] != null && property['gallery'].isNotEmpty) {
              imageUrl = property['gallery'][0]['original'];
            } else if (property['image'] != null &&
                property['image'].isNotEmpty) {
              imageUrl = property['image'];
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  // Utiliser la fonction de navigation unifiée
                  navigateToPropertyDetails(property);
                },
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          bottomLeft: Radius.circular(12.0),
                        ),
                        child: Image.network(
                          imageUrl,
                          width: 120.0,
                          height: 120.0,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 120.0,
                            height: 120.0,
                            color: Colors.grey[100],
                            child: const Icon(
                              Icons.photo_library_outlined,
                              color: Colors.grey,
                              size: 32.0,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(
                                    color: Colors.blue[100]!,
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  getCategoryName(property,
                                      languageController.locale.languageCode),
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Obx(() {
                                final price =
                                    property['price']?.toDouble() ?? 0.0;
                                final convertedPrice =
                                    currencyController.convertPrice(price);
                                return Text(
                                  "${convertedPrice.toStringAsFixed(0)} ${currencyController.getCurrentSymbol()}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    fontSize: 16.0,
                                  ),
                                );
                              }),
                              const SizedBox(height: 4.0),
                              Text(
                                property['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.0,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4.0),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      size: 14.0, color: Colors.grey[400]),
                                  const SizedBox(width: 4.0),
                                  Expanded(
                                    child: Text(
                                      property['structure']?['name'] ??
                                          'Localisation non disponible',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: _buildFeatureItem(
                                      '${property['bedroom'] ?? 0} ${l10n.bedrooms}',
                                      Icons.king_bed_outlined,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildFeatureItem(
                                      '${property['bathroom'] ?? 0} ${l10n.bathrooms}',
                                      Icons.bathtub_outlined,
                                    ),
                                  ),
                                  if (![
                                    'apartment',
                                    'hostel',
                                    'office',
                                    'store'
                                  ].contains(property['categories']?['slug']))
                                    Expanded(
                                      child: _buildFeatureItem(
                                        '${property['area']?.toInt() ?? 0} ${l10n.square_meters}',
                                        Icons.square_foot,
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
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.0, color: const Color(0xFF231717)),
        const SizedBox(width: 4.0),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.0,
              color: Color(0xFF231717),
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/articles/filter_controller.dart';
import 'package:immolink_mobile/controllers/home/categories_controller.dart';
import 'package:immolink_mobile/controllers/currency/currency_controller.dart';
import 'package:immolink_mobile/l10n/app_localizations.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final RxBool _filtersApplied = false.obs;

  @override
  Widget build(BuildContext context) {
    final FilterController filterController = Get.find<FilterController>();
    final CategoryController categoryController =
        Get.find<CategoryController>();
    final CurrencyController currencyController =
        Get.find<CurrencyController>();
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      if (_filtersApplied.value) {
        // Affiche uniquement l'overlay des résultats, sans Scaffold ni AppBar
        return Material(
          color: Colors.white,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: _buildResultsOverlay(context),
          ),
        );
      } else {
        // Affiche le Scaffold normal avec AppBar et filtres
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(l10n.filters),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  filterController.clearFilters();
                },
                child: Text(
                  l10n.reset,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              // Contenu principal
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type de transaction
                    Text(
                      l10n.transaction_type,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Obx(() => Row(
                          children: [
                            Expanded(
                              child: _buildFilterChip(
                                l10n.for_sale,
                                filterController.isForSellSelected.value,
                                () => filterController.toggleForSell(true),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: _buildFilterChip(
                                l10n.for_rent,
                                !filterController.isForSellSelected.value,
                                () => filterController.toggleForSell(false),
                              ),
                            ),
                          ],
                        )),
                    const SizedBox(height: 24.0),

                    // Type de propriété
                    Text(
                      l10n.property_type,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Obx(() => Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            _buildFilterChip(
                              l10n.all,
                              filterController.selectedPropertyType.value ==
                                  'All',
                              () => filterController.selectPropertyType('All'),
                            ),
                            ...categoryController.categories.map((category) {
                              final name = category['name'] as String;
                              final id = category['id'].toString();
                              return _buildFilterChip(
                                name,
                                filterController.selectedPropertyType.value ==
                                    id,
                                () => filterController.selectPropertyType(id),
                              );
                            }).toList(),
                          ],
                        )),
                    const SizedBox(height: 24.0),

                    // Prix
                    Text(
                      l10n.property_price,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: filterController.minPriceController,
                            onChanged: filterController.updateMinPrice,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Min',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8.0,
                              ),
                              suffix: Obx(() => Text(
                                    currencyController.getCurrentSymbol(),
                                    style: const TextStyle(color: Colors.grey),
                                  )),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            controller: filterController.maxPriceController,
                            onChanged: filterController.updateMaxPrice,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Max',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8.0,
                              ),
                              suffix: Obx(() => Text(
                                    currencyController.getCurrentSymbol(),
                                    style: const TextStyle(color: Colors.grey),
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),

                    // Superficie
                    Text(
                      l10n.property_area,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: filterController.minAreaController,
                            onChanged: filterController.updateMinArea,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Min m²',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            controller: filterController.maxAreaController,
                            onChanged: filterController.updateMaxArea,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Max m²',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),

                    // Période de publication
                    Text(
                      l10n.published,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Obx(() => Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            _buildFilterChip(
                              l10n.anytime,
                              filterController.selectedPostedSince.value ==
                                  'Anytime',
                              () =>
                                  filterController.selectPostedSince('Anytime'),
                            ),
                            _buildFilterChip(
                              l10n.today,
                              filterController.selectedPostedSince.value ==
                                  'Today',
                              () => filterController.selectPostedSince('Today'),
                            ),
                            _buildFilterChip(
                              l10n.this_week,
                              filterController.selectedPostedSince.value ==
                                  'ThisWeek',
                              () => filterController
                                  .selectPostedSince('ThisWeek'),
                            ),
                            _buildFilterChip(
                              l10n.this_month,
                              filterController.selectedPostedSince.value ==
                                  'ThisMonth',
                              () => filterController
                                  .selectPostedSince('ThisMonth'),
                            ),
                          ],
                        )),
                    const SizedBox(height: 32.0),

                    // Bouton Appliquer
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() => ElevatedButton(
                            onPressed: filterController.isLoading.value
                                ? null
                                : () async {
                                    // Appliquer les filtres directement sans navigation
                                    await filterController.applyFilters();
                                    _filtersApplied.value = true;
                                    // Ne pas naviguer, rester sur le même écran
                                    // Get.back();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: filterController.isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text(
                                    l10n.apply_filters,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[700] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
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

  String _getAreaValue(dynamic area) {
    if (area == null) return '0';

    if (area is int) {
      return area.toString();
    } else if (area is double) {
      return area.toInt().toString();
    } else if (area is String) {
      try {
        final doubleValue = double.parse(area);
        return doubleValue.toInt().toString();
      } catch (e) {
        return '0';
      }
    } else {
      return '0';
    }
  }

  double _getPriceValue(dynamic price) {
    if (price == null) return 0.0;

    if (price is int) {
      return price.toDouble();
    } else if (price is double) {
      return price;
    } else if (price is String) {
      try {
        return double.parse(price);
      } catch (e) {
        return 0.0;
      }
    } else {
      return 0.0;
    }
  }

  Widget _buildResultsOverlay(BuildContext context) {
    final FilterController filterController = Get.find<FilterController>();
    final CurrencyController currencyController =
        Get.find<CurrencyController>();
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      if (!_filtersApplied.value) {
        return const SizedBox.shrink();
      }

      if (filterController.isLoading.value) {
        return Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        _filtersApplied.value = false;
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Recherche en cours...',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Recherche de propriétés...',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Veuillez patienter',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (filterController.filteredProperties.isNotEmpty) {
        return Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          _filtersApplied.value = false;
                        },
                      ),
                      Expanded(
                        child: Text(
                          'Résultats (${filterController.filteredProperties.length})',
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16.0,
                              color: Colors.green[700],
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              'Trouvé',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filterController.filteredProperties.length,
                    itemBuilder: (context, index) {
                      final property =
                          filterController.filteredProperties[index];
                      final Map<String, dynamic> propertyData =
                          property as Map<String, dynamic>;

                      String imageUrl = '';
                      if (propertyData['gallery'] != null &&
                          propertyData['gallery'] is List &&
                          (propertyData['gallery'] as List).isNotEmpty) {
                        final galleryItem =
                            (propertyData['gallery'] as List).first;
                        if (galleryItem is Map<String, dynamic>) {
                          imageUrl = galleryItem['original'] ?? '';
                        }
                      } else if (propertyData['image'] != null) {
                        imageUrl = propertyData['image'] as String;
                      }

                      final language = Get.locale?.languageCode ?? 'fr';
                      String name = '';

                      if (propertyData['translations'] != null &&
                          propertyData['translations']
                              is Map<String, dynamic>) {
                        final translations = propertyData['translations']
                            as Map<String, dynamic>;
                        if (translations[language] != null &&
                            translations[language] is Map<String, dynamic>) {
                          name = translations[language]['name'] ?? '';
                        }
                      }

                      if (name.isEmpty) {
                        name = propertyData['name'] ?? 'Propriété sans nom';
                      }

                      String categoryName = 'Catégorie';
                      String categoryImage = '';
                      if (propertyData['category'] != null &&
                          propertyData['category'] is Map<String, dynamic>) {
                        final category =
                            propertyData['category'] as Map<String, dynamic>;
                        categoryName = category['name'] ?? 'Catégorie';
                        categoryImage = category['image'] ?? '';
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
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
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.0),
                            onTap: () {
                              // Navigation vers les détails de la propriété
                              // TODO: Implémenter la navigation
                            },
                            child: Row(
                              children: [
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
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      width: 110.0,
                                      height: 110.0,
                                      color: Colors.grey[100],
                                      child: const Icon(
                                          Icons.photo_library_outlined,
                                          color: Colors.grey),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6.0,
                                                      vertical: 2.0),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                                border: Border.all(
                                                    color: Colors.blue[100]!,
                                                    width: 1.0),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (categoryImage.isNotEmpty)
                                                    Image.network(
                                                      categoryImage,
                                                      height: 12,
                                                      width: 12,
                                                    ),
                                                  if (categoryImage.isNotEmpty)
                                                    const SizedBox(width: 4),
                                                  Text(
                                                    categoryName,
                                                    style: TextStyle(
                                                      color: Colors.blue[800],
                                                      fontSize: 9.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 4.0),
                                            Obx(() {
                                              final price =
                                                  propertyData['price'] ?? 0;
                                              final doublePrice =
                                                  _getPriceValue(price);
                                              final convertedPrice =
                                                  currencyController
                                                      .convertPrice(
                                                          doublePrice);
                                              return Text(
                                                "${convertedPrice.toStringAsFixed(0)} ${currencyController.getCurrentSymbol()}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue,
                                                  fontSize: 13.0,
                                                ),
                                              );
                                            }),
                                            const SizedBox(height: 4.0),
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13.0,
                                                height: 1.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildAmenity(
                                                Icons.king_bed_outlined,
                                                '${propertyData['bedroom'] ?? 0}'),
                                            _buildAmenity(
                                                Icons.bathtub_outlined,
                                                '${propertyData['bathroom'] ?? 0}'),
                                            if (![
                                              'apartment',
                                              'hostel',
                                              'office',
                                              'store'
                                            ].contains(propertyData['category']
                                                ?['slug']))
                                              _buildAmenity(Icons.square_foot,
                                                  '${_getAreaValue(propertyData['area'])} m²'),
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
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        _filtersApplied.value = false;
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Aucun résultat',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
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
                        'Aucune propriété trouvée',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Essayez de modifier vos critères de recherche',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }
}

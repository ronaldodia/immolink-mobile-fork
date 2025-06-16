import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/articles/filter_controller.dart';
import 'package:immolink_mobile/controllers/home/categories_controller.dart';
import 'package:immolink_mobile/l10n/app_localizations.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late TextEditingController minPriceController;
  late TextEditingController maxPriceController;
  late TextEditingController minAreaController;
  late TextEditingController maxAreaController;

  @override
  void initState() {
    super.initState();
    final filterController = Get.find<FilterController>();
    minPriceController =
        TextEditingController(text: filterController.minPrice.value);
    maxPriceController =
        TextEditingController(text: filterController.maxPrice.value);
    minAreaController =
        TextEditingController(text: filterController.minArea.value);
    maxAreaController =
        TextEditingController(text: filterController.maxArea.value);
  }

  @override
  void dispose() {
    minPriceController.dispose();
    maxPriceController.dispose();
    minAreaController.dispose();
    maxAreaController.dispose();
    super.dispose();
  }

  bool isHouseCategory(String? categoryName) {
    if (categoryName == null) return false;
    final name = categoryName.toLowerCase();
    return name == 'maison' ||
        name == 'house' ||
        name == 'villa' ||
        name == 'منزل' ||
        name == 'بيت';
  }

  @override
  Widget build(BuildContext context) {
    final FilterController filterController = Get.find<FilterController>();
    final CategoryController categoryController =
        Get.find<CategoryController>();
    final l10n = AppLocalizations.of(context)!;

    void applyFilters() {
      filterController.minPrice.value = minPriceController.text;
      filterController.maxPrice.value = maxPriceController.text;

      if (isHouseCategory(categoryController.selectedCategory.value)) {
        filterController.minArea.value = minAreaController.text;
        filterController.maxArea.value = maxAreaController.text;
      } else {
        filterController.minArea.value = '';
        filterController.maxArea.value = '';
      }
      filterController.applyFilters();
    }

    void clearFilters() {
      filterController.clearFilters();
      minPriceController.clear();
      maxPriceController.clear();
      minAreaController.clear();
      maxAreaController.clear();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.filter),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Get.previousRoute == '/filter-results') {
              Get.back();
            } else {
              Get.until((route) => route.settings.name == '/home');
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: clearFilters,
            child: Text(
              l10n.clear_filter,
              style: const TextStyle(color: Colors.teal),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type de transaction (Vente/Location)
            Row(
              children: [
                Expanded(
                  child: Obx(() => ElevatedButton(
                        onPressed: () => filterController.toggleForSell(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              filterController.isForSellSelected.value
                                  ? Colors.blue[700]
                                  : Colors.grey[200],
                        ),
                        child: Text(
                          l10n.for_sale,
                          style: TextStyle(
                            color: filterController.isForSellSelected.value
                                ? Colors.white
                                : Colors.grey[700],
                          ),
                        ),
                      )),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => ElevatedButton(
                        onPressed: () => filterController.toggleForSell(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              !filterController.isForSellSelected.value
                                  ? Colors.blue[700]
                                  : Colors.grey[200],
                        ),
                        child: Text(
                          l10n.for_rent,
                          style: TextStyle(
                            color: !filterController.isForSellSelected.value
                                ? Colors.white
                                : Colors.grey[700],
                          ),
                        ),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Type de propriété
            Text(l10n.property_type, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Obx(() {
              if (categoryController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // Filtrage des catégories comme dans create_article_screen.dart
              final filteredCategories =
                  categoryController.categories.where((category) {
                final categoryName = category['name'].toString().toLowerCase();
                return categoryName != 'hostel' &&
                    categoryName != 'hôtel' &&
                    categoryName != 'الفندق';
              }).toList();

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: filteredCategories.map((category) {
                  final name = category['name'];
                  return PropertyTypeButton(
                    label: name,
                    isSelected:
                        categoryController.selectedCategory.value == name,
                    onTap: () => categoryController.selectCategory(name),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 16),

            // Budget (Price)
            Text(l10n.budget, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: minPriceController,
                    decoration: InputDecoration(
                      hintText: l10n.min_price,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: maxPriceController,
                    decoration: InputDecoration(
                      hintText: l10n.max_price,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Superficie (uniquement pour les maisons)
            Obx(() {
              final selectedCategory =
                  categoryController.selectedCategory.value;

              if (isHouseCategory(selectedCategory)) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.surface_area,
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minAreaController,
                            decoration: InputDecoration(
                              hintText: l10n.min_area,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: maxAreaController,
                            decoration: InputDecoration(
                              hintText: l10n.max_area,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            // Bouton Apply Filters
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: applyFilters,
                child: Text(l10n.apply_filters),
              ),
            ),
            const SizedBox(height: 16),

            // Résultats des filtres
            if (filterController.isLoading.value)
              const Center(child: CircularProgressIndicator())
            else if (filterController.filteredProperties.isEmpty)
              Center(child: Text(l10n.no_properties_found))
          ],
        ),
      ),
    );
  }
}

class PropertyTypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const PropertyTypeButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

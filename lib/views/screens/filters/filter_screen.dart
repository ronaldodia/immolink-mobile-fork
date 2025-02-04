import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/articles/filter_controller.dart';
import 'package:immolink_mobile/controllers/home/categories_controller.dart';

class FilterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FilterController filterController = Get.put(FilterController());
    final CategoryController categoryController = Get.put(CategoryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter'),
        actions: [
          TextButton(
            onPressed: filterController.clearFilters,
            child: const Text(
              'Clear Filter',
              style: TextStyle(color: Colors.teal),
            ),
          ),
        ],
      ),
      body: Obx(() => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Onglets For Sell / For Rent
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilterTab(
                    label: 'For Sell',
                    isSelected: filterController.isForSellSelected.value,
                    onTap: () => filterController.toggleForSell(true),
                  ),
                  FilterTab(
                    label: 'For Rent',
                    isSelected: !filterController.isForSellSelected.value,
                    onTap: () => filterController.toggleForSell(false),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Property Type
              const Text('Property Type', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Obx(() {
                if (categoryController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final filteredCategories = categoryController.categories.where((category) {
                  final name = category['name'];
                  return name != 'Hotel' && name != 'فندق' && name != 'Hôtel';
                }).toList();

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: filteredCategories.map((category) {
                    final name = category['name'];
                    return PropertyTypeButton(
                      label: name,
                      isSelected: categoryController.selectedCategory.value == name,
                      onTap: () => categoryController.selectCategory(name),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 16),

              // Budget (Price)
              const Text('Budget (Price)', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) => filterController.minPrice.value = value,
                      decoration: const InputDecoration(
                        hintText: 'Min Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (value) => filterController.maxPrice.value = value,

                      decoration: const InputDecoration(
                        hintText: 'Max Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bouton Apply Filters
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: filterController.applyFilters,
                  child: const Text('Apply Filters'),
                ),
              ),
              const SizedBox(height: 16),

              // Résultats des filtres
              if (filterController.isLoading.value)
                const Center(child: CircularProgressIndicator())
              else if (filterController.filteredProperties.isEmpty)
                const Center(child: Text('No properties found.'))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filterController.filteredProperties.length,
                  itemBuilder: (context, index) {
                    final property = filterController.filteredProperties[index];
                    return ListTile(
                      leading: property['image'] != null ? Image.network(property['image'], fit: BoxFit.cover) : const Icon(Icons.image_not_supported),
                      title: Text(property['name_fr'] ?? 'Nom indisponible'),
                      subtitle: Text('${property['price']} USD'),
                    );
                  },
                ),
            ],
          ),
        ),
      )),
    );
  }
}


class FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterTab(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.teal : Colors.teal[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class PropertyTypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const PropertyTypeButton(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.teal[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.teal[100]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.teal,
          ),
        ),
      ),
    );
  }
}

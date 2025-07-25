import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:immolink_mobile/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:immolink_mobile/controllers/currency/currency_controller.dart';

class FilterController extends GetxController {
  // Variables existantes
  var isForSellSelected = true.obs;
  var selectedPropertyType = 'All'.obs;
  var minPrice = ''.obs;
  var maxPrice = ''.obs;
  var minArea = ''.obs;
  var maxArea = ''.obs;
  var selectedPostedSince = 'Anytime'.obs;
  var location = ''.obs;
  var selectedFacilities = <String>[].obs;
  final filteredArticles = [].obs;

  // Résultats du filtre
  var filteredProperties = [].obs;
  var isLoading = false.obs;

  // Contrôleurs pour les champs de saisie
  late final TextEditingController minPriceController;
  late final TextEditingController maxPriceController;
  late final TextEditingController minAreaController;
  late final TextEditingController maxAreaController;

  @override
  void onInit() {
    super.onInit();
    // Initialiser les contrôleurs
    minPriceController = TextEditingController(text: minPrice.value);
    maxPriceController = TextEditingController(text: maxPrice.value);
    minAreaController = TextEditingController(text: minArea.value);
    maxAreaController = TextEditingController(text: maxArea.value);
  }

  @override
  void onClose() {
    // Ne pas disposer les contrôleurs ici car ils sont toujours utilisés
    // Les contrôleurs seront automatiquement disposés quand le GetXController est supprimé
    super.onClose();
  }

  // Réinitialisation des filtres
  void clearFilters() {
    // Réinitialiser les valeurs observables
    isForSellSelected.value = true;
    selectedPropertyType.value = 'All';
    minPrice.value = '';
    maxPrice.value = '';
    minArea.value = '';
    maxArea.value = '';
    selectedPostedSince.value = 'Anytime';

    // Réinitialiser les contrôleurs de texte
    minPriceController.text = '';
    maxPriceController.text = '';
    minAreaController.text = '';
    maxAreaController.text = '';
  }

  // Mettre à jour les valeurs observables quand les contrôleurs changent
  void updateMinPrice(String value) {
    minPrice.value = value;
  }

  void updateMaxPrice(String value) {
    maxPrice.value = value;
  }

  void updateMinArea(String value) {
    minArea.value = value;
  }

  void updateMaxArea(String value) {
    maxArea.value = value;
  }

  // Changement d'état pour For Sell / For Rent
  void toggleForSell(bool isSell) {
    isForSellSelected.value = isSell;
  }

  // Sélection de type de propriété
  void selectPropertyType(String type) {
    selectedPropertyType.value = type;
  }

  // Sélection de période de publication
  void selectPostedSince(String period) {
    selectedPostedSince.value = period;
  }

  // Ajout ou suppression des installations
  void toggleFacility(String facility) {
    if (selectedFacilities.contains(facility)) {
      selectedFacilities.remove(facility);
    } else {
      selectedFacilities.add(facility);
    }
  }

  Future<void> applyFilters() async {
    isLoading.value = true;

    // Récupérer le CurrencyController pour la conversion
    final CurrencyController currencyController =
        Get.find<CurrencyController>();

    // Convertir les prix de la devise sélectionnée vers MRU
    String? minPriceInMRU;
    String? maxPriceInMRU;

    if (minPrice.value.isNotEmpty) {
      try {
        final minPriceValue = double.parse(minPrice.value);
        final minPriceConverted =
            currencyController.convertToMRU(minPriceValue);
        minPriceInMRU = minPriceConverted.toStringAsFixed(0);
        print(
            'Min price converted: ${minPrice.value} ${currencyController.getCurrentSymbol()} → $minPriceInMRU MRU');
      } catch (e) {
        print('Error converting min price: $e');
        minPriceInMRU =
            minPrice.value; // Garder la valeur originale en cas d'erreur
      }
    }

    if (maxPrice.value.isNotEmpty) {
      try {
        final maxPriceValue = double.parse(maxPrice.value);
        final maxPriceConverted =
            currencyController.convertToMRU(maxPriceValue);
        maxPriceInMRU = maxPriceConverted.toStringAsFixed(0);
        print(
            'Max price converted: ${maxPrice.value} ${currencyController.getCurrentSymbol()} → $maxPriceInMRU MRU');
      } catch (e) {
        print('Error converting max price: $e');
        maxPriceInMRU =
            maxPrice.value; // Garder la valeur originale en cas d'erreur
      }
    }

    // Construire les paramètres de requête avec les prix convertis en MRU
    final queryParams = {
      'category_id': selectedPropertyType.value != 'All'
          ? selectedPropertyType.value
          : null,
      'minprice': minPriceInMRU,
      'maxprice': maxPriceInMRU,
      'minarea': minArea.value.isNotEmpty ? minArea.value : null,
      'maxarea': maxArea.value.isNotEmpty ? maxArea.value : null,
      'purpose': isForSellSelected.value ? 'Sell' : 'Rent',
    };

    // Supprimer les paramètres nulls
    queryParams.removeWhere((key, value) => value == null);

    final uri = Uri.parse('${Config.baseUrlApp}/home/filter_properties')
        .replace(queryParameters: queryParams);
    print('API: Filters $uri');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Filter response: $data');
        filteredProperties.value = data['data'] ?? [];
        print('Filtered properties count: ${filteredProperties.length}');
        // Ne pas naviguer automatiquement, laisser l'écran gérer l'affichage
        // Get.to(() => const FilteredPropertiesScreen());
      } else {
        print('Filter API error: ${response.statusCode}');
        Get.snackbar('Erreur', 'Impossible de récupérer les propriétés.');
      }
    } catch (e) {
      print('Filter API exception: $e');
      Get.snackbar('Erreur', 'Une erreur est survenue: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

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

  // Réinitialisation des filtres
  void clearFilters() {
    isForSellSelected.value = true;
    selectedPropertyType.value = 'All';
    minPrice.value = '';
    maxPrice.value = '';
    minArea.value = '';
    maxArea.value = '';
    selectedPostedSince.value = 'Anytime';
    location.value = '';
    selectedFacilities.clear();
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

    // Construire les paramètres de requête
    final queryParams = {
      'category_id': selectedPropertyType.value != 'All' ? selectedPropertyType.value : null,
      'minprice': minPrice.value.isNotEmpty ? minPrice.value : null,
      'maxprice': maxPrice.value.isNotEmpty ? maxPrice.value : null,
      'minarea': minArea.value.isNotEmpty ? minArea.value : null,
      'maxarea': maxArea.value.isNotEmpty ? maxArea.value : null,
      'purpose': isForSellSelected.value ? 'Sell' : 'Rent',
    };

    // Supprimer les paramètres nulls
    queryParams.removeWhere((key, value) => value == null);

    final uri = Uri.parse('http://daar.server1.digissimmo.org/mobile/home/filter_properties')
        .replace(queryParameters: queryParams);
    print('API: Filters $uri');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        filteredProperties.value = data['data'];
      } else {
        Get.snackbar('Error', 'Failed to fetch properties.');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

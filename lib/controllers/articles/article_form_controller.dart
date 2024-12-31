import 'dart:convert';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:get/get.dart';
import 'package:immolink_mobile/services/address_service.dart';
import 'package:immolink_mobile/utils/config.dart';

class ArticleFormController extends GetxController {
  // Champs du formulaire
  var nameAr = "".obs;
  var categoryId = 0.obs;
  var authorId = 0.obs;
  var districtId = 0.obs;
  var bookableType = "Daily".obs;
  var purpose = "Rent".obs;
  var price = "".obs;
  var locationLatitude = "".obs;
  var locationLongitude = "".obs;
  var language = "en".obs;
  var area = "".obs;
  var floorPlan = "".obs;
  var status = "publish".obs;
  var bedroom = "".obs;
  var bathroom = "".obs;
  var description = "".obs;
  var gallery = <Map<String, String>>[].obs;
  var image = "".obs;

  // addressage
  RxList<String> moughataas = <String>[].obs;
  RxList<String> lotissements = <String>[].obs;
  RxString selectedMoughataa = ''.obs;
  RxString selectedLotissement = ''.obs;
  RxString selectedLot = ''.obs;
  RxList<dynamic> locationData = <dynamic>[].obs;
  Rx<LatLng> currentLocation = LatLng(0.0, 0.0).obs;

  // Champs observables pour l'image en avant et la galerie d'images
  RxString uploadImage = ''.obs;
  RxList<Map<String, String>> uploadGallery = <Map<String, String>>[].obs;

  RxBool isPanelOpen = false.obs;
  // Rx<LatLng> currentLocation =
  //     const LatLng(18.060137615952126, -15.96000274888616).obs;
  // RxList locationData = [].obs;
  var addressData = {}.obs;

  var isLoadingImage = false.obs;
  var isLoadingGallery = false.obs;

  // Étape actuelle
  var currentStep = 0.obs;


  @override
  void onInit() {
    super.onInit();
    loadData();
  } // Méthode pour aller à une étape spécifique
  void goToStep(int step) {
    currentStep.value = step;
  }

  // Soumettre le formulaire
  Future<void> submitForm() async {
    final payload = {
      'name_ar': nameAr.value,
      'category_id': categoryId.value,
      'author_id': authorId.value,
      'district_id': districtId.value,
      'bookable_type': bookableType.value,
      'purpose': purpose.value,
      'price': price.value,
      'location_latitude': locationLatitude.value,
      'location_longitude': locationLongitude.value,
      'language': language.value,
      'area': area.value,
      'floor_plan': floorPlan.value,
      'status': status.value,
      'bedroom': bedroom.value,
      'bathroom': bathroom.value,
      'description': description.value,
      'gallery': gallery.map((item) => item).toList(),
      'image': image.value,
    };

    // Exemple de soumission à l'API
    print("Payload envoyé : $payload");
    // Ajoutez ici la logique HTTP POST pour envoyer les données
  }

  // URL de l'API
  final String apiUrl = '${Config.initUrl}/api/attachments';

  // Méthode pour uploader une image unique
  Future<void> uploadImageFile(File file) async {
    isLoadingImage.value = true;
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..headers['Accept'] = 'application/json'
        ..files
            .add(await http.MultipartFile.fromPath('attachment[]', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var responseData = json.decode(responseBody);

        if (responseData.isNotEmpty) {
          uploadImage.value = responseData[0]['thumbnail'];
        }
      } else {
        print(
            'Erreur lors du téléchargement de l\'image : ${response.statusCode}');
      }
    } catch (e) {
      print('Exception lors du téléchargement de l\'image : $e');
    } finally {
      isLoadingImage.value = false;
    }
  }

  // Méthode pour uploader plusieurs images (galerie)
  Future<void> uploadGalleryImages(List<File> files) async {
    isLoadingGallery.value = true; // Affiche le chargement
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..headers['Accept'] = 'application/json';

      for (var file in files) {
        request.files
            .add(await http.MultipartFile.fromPath('attachment[]', file.path));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var responseData = json.decode(responseBody);

        if (responseData is List) {
          uploadGallery.addAll(responseData.map<Map<String, String>>((image) {
            // Vérifie si chaque élément contient bien les clés nécessaires
            if (image is Map &&
                image.containsKey('thumbnail') &&
                image.containsKey('original')) {
              return {
                'thumbnail': image['thumbnail']?.toString() ?? '',
                'original': image['original']?.toString() ?? '',
              };
            } else {
              return {};
            }
          }).toList());
        }
      } else {
        print(
            'Erreur lors du téléchargement des images : ${response.statusCode}');
      }
    } catch (e) {
      print('Exception lors du téléchargement des images : $e');
    } finally {
      isLoadingGallery.value = false; // Cache le chargement
    }

    Future<void> fetchLocationData(double latitude, double longitude) async {
      try {
        final url =
            'https://gis.digissimmo.org/api/location?longitude=$longitude&latitude=$latitude';
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          locationData.assignAll(data);
        } else {
          print('Erreur API : ${response.statusCode}');
        }
      } catch (e) {
        print('Exception lors de la récupération des données : $e');
      }
    }

    void togglePanel() {
      isPanelOpen.value = !isPanelOpen.value;
    }

    void setCurrentLocation(LatLng location) {
      currentLocation.value = location;
      fetchLocationData(location.latitude, location.longitude);
    }
  }

  // Méthode pour supprimer une image de la galerie
  void removeImageFromGallery(Map<String, String> image) {
    uploadGallery.remove(image);
  }

  // Méthode pour supprimer l'image en avant
  void removeImage() {
    uploadImage.value = '';
  }

  void togglePanel() {
    isPanelOpen.value = !isPanelOpen.value;
  }

  void setCurrentLocation(LatLng location) async {
    currentLocation.value = location;
    await fetchLocationData(location.latitude, location.longitude);
  }

  Future<void> fetchLocationData(double latitude, double longitude) async {
    final url =
        'https://gis.digissimmo.org/api/location?longitude=$longitude&latitude=$latitude';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      locationData.value = jsonDecode(response.body);
    } else {
      locationData.value = [];
    }
  }

  void searchLocation(String query) {
    // Implémentez une recherche personnalisée pour trouver des endroits.
  }


  Future<void> loadData() async {
    final data = await AddressService().loadAddressData();
    addressData.value = data;
    moughataas.value = data.keys.toList();
  }

  void selectMoughataa(String moughataa) {
    selectedMoughataa.value = moughataa;

    // Assurez-vous que 'lotissements' contient uniquement des Strings.
    var rawLotissements = addressData[moughataa]['lotissements'] ?? [];
    if (rawLotissements is List<dynamic>) {
      lotissements.value = rawLotissements.map((item) => item.toString()).toList();
    } else {
      lotissements.value = [];
    }
  }


  void selectLotissement(String lotissement) {
    selectedLotissement.value = lotissement;
  }

  void selectLot(String lot) {
    selectedLot.value = lot;
  }

  Future<void> fetchFeatures() async {
    final response = await GetConnect().get(
      'https://gis.digissimmo.org/api/features',
      query: {
        'lot': selectedLot.value,
        'lotissement': selectedLotissement.value,
        'moughataa': selectedMoughataa.value,
      },
    );
    if (response.statusCode == 200) {
      locationData.value = response.body;
    }
  }

}

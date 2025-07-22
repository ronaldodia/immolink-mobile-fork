import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import 'package:get/get.dart';
import 'package:immolink_mobile/services/address_service.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/views/widgets/loaders/loader.dart';
import 'package:location/location.dart';

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
  Rx<LatLng> currentLocation =
      const LatLng(0.0, 0.0).obs; // Exemple pour Nouakchott
  GoogleMapController? mapController;
  final Location location = Location();

  RxList<Polygon> polygons = <Polygon>[].obs;
  RxBool isLoading = false.obs;

  // Champs observables pour l'image en avant et la galerie d'images
  RxString uploadImage = ''.obs;
  RxList<Map<String, String>> uploadGallery = <Map<String, String>>[].obs;

  RxBool isPanelOpen = false.obs;
  var addressData = {}.obs;

  var isLoadingImage = false.obs;
  var isLoadingGallery = false.obs;

  // Étape actuelle
  var currentStep = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    _initLocation();
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
      // Compression avant upload
      final compressed = await compressImage(file);
      if (compressed == null) {
        DLoader.errorSnackBar(
            title: 'Erreur', message: 'Impossible de compresser l\'image.');
        return;
      }
      if (await compressed.length() > 2 * 1024 * 1024) {
        DLoader.errorSnackBar(
            title: 'Image trop lourde',
            message: 'Veuillez choisir une image de moins de 2 Mo.');
        return;
      }
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..headers['Accept'] = 'application/json'
        ..files.add(
            await http.MultipartFile.fromPath('attachment[]', compressed.path));
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var responseData = json.decode(responseBody);
        if (responseData.isNotEmpty && responseData[0]['original'] != null) {
          uploadImage.value = responseData[0]['original'];
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
    isLoadingGallery.value = true;
    try {
      List<File> compressedFiles = [];
      for (var file in files) {
        final compressed = await compressImage(file);
        if (compressed == null) {
          DLoader.errorSnackBar(
              title: 'Erreur', message: 'Impossible de compresser une image.');
          continue;
        }
        if (await compressed.length() > 2 * 1024 * 1024) {
          DLoader.errorSnackBar(
              title: 'Image trop lourde',
              message: 'Une image de la galerie dépasse 2 Mo.');
          continue;
        }
        compressedFiles.add(compressed);
      }
      if (compressedFiles.isEmpty) return;
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..headers['Accept'] = 'application/json';
      for (var file in compressedFiles) {
        request.files
            .add(await http.MultipartFile.fromPath('attachment[]', file.path));
      }
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var responseData = json.decode(responseBody);
        if (responseData is List) {
          uploadGallery.addAll(responseData.map<Map<String, String>>((image) {
            if (image is Map &&
                image.containsKey('thumbnail') &&
                image.containsKey('original')) {
              return {
                'thumbnail': image['thumbnail']?.toString() ?? '',
                'original': image['original']?.toString() ?? '',
                'id': image['id']?.toString() ?? '',
              };
            } else {
              return {};
            }
          }).toList());
        }
      } else if (response.statusCode == 413) {
        DLoader.errorSnackBar(
            title: 'Erreur', message: 'Une image de la galerie dépasse 2 Mo.');
      } else {
        print(
            'Erreur lors du téléchargement des images : ${response.statusCode}');
        DLoader.errorSnackBar(
            title: 'Erreur',
            message:
                'Une erreur est survenue lors du téléchargement des images.');
      }
    } catch (e) {
      print('Exception lors du téléchargement des images : $e');
    } finally {
      isLoadingGallery.value = false;
    }
  }

  Future<void> fetchLocationData(double latitude, double longitude) async {
    isLoading.value = true; // Active le chargement
    try {
      final url =
          '${Config.baseUrlSIG}/location?longitude=$longitude&latitude=$latitude';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Effacer les polygones précédents
        polygons.clear();

        if (data.isNotEmpty) {
          locationData.value = data;
          final geometry = data[0]['geometry'];

          if (geometry != null) {
            final coordinates = geometry['coordinates'];
            if (coordinates != null && coordinates.isNotEmpty) {
              List<LatLng> polygonCoords = [];
              for (var point in coordinates[0][0]) {
                polygonCoords.add(LatLng(point[1], point[0]));
              }

              // Ajouter le nouveau polygone
              final polygon = Polygon(
                polygonId: const PolygonId('selectedPolygon'),
                points: polygonCoords,
                fillColor: Colors.red.withOpacity(0.3),
                strokeColor: Colors.red,
                strokeWidth: 2,
              );
              polygons.add(polygon);
            }
          } else {
            DLoader.warningSnackBar(
              title: 'Localisation',
              message: "Aucune donnée trouvée pour l'emplacement spécifié.",
            );
          }
        }
      } else {
        print('Erreur API : ${response.statusCode}');
      }
    } catch (e) {
      print('Exception lors de la récupération des données : $e');
    } finally {
      isLoading.value = false; // Désactive le chargement
    }
  }

  void togglePanel() {
    isPanelOpen.value = !isPanelOpen.value;
  }

  // Méthode pour supprimer une image de la galerie
  void removeImageFromGallery(Map<String, String> image) {
    uploadGallery.remove(image);
  }

  // Méthode pour supprimer l'image en avant
  void removeImage() {
    uploadImage.value = '';
  }

  void setCurrentLocation(LatLng location) async {
    currentLocation.value = location;

    // Efface les anciens polygones et supprime les marqueurs
    polygons.clear();

    // Rechercher les données pour la nouvelle localisation
    await fetchLocationData(location.latitude, location.longitude);
    // Si des polygones sont présents, ajustez la caméra pour inclure tous leurs points
    if (polygons.isNotEmpty) {
      final polygonPoints = polygons.first.points;

      if (polygonPoints.isNotEmpty) {
        final bounds = LatLngBounds(
          southwest: polygonPoints.reduce((a, b) => LatLng(
              a.latitude < b.latitude ? a.latitude : b.latitude,
              a.longitude < b.longitude ? a.longitude : b.longitude)),
          northeast: polygonPoints.reduce((a, b) => LatLng(
              a.latitude > b.latitude ? a.latitude : b.latitude,
              a.longitude > b.longitude ? a.longitude : b.longitude)),
        );

        mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
        return;
      }
    }

    // Mettre à jour la position de la caméra
    mapController?.animateCamera(
      CameraUpdate.newLatLng(location),
    );
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
    lotissements.clear(); // Réinitialiser les lotissements
    selectedLotissement.value = ''; // Réinitialiser la sélection
    selectedLot.value = ''; // Réinitialiser les lots
    // Charger les nouveaux lotissements
    var rawLotissements = addressData[moughataa]['lotissements'] ?? [];
    if (rawLotissements is List<dynamic>) {
      lotissements.value =
          rawLotissements.map((item) => item.toString()).toList();
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
    isLoading.value = true;
    try {
      final response = await GetConnect().get(
        '${Config.baseUrlSIG}/features',
        query: {
          'lot': selectedLot.value,
          'lotissement': selectedLotissement.value,
          'moughataa': selectedMoughataa.value,
        },
      );

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;

        if (data.isNotEmpty) {
          locationData.value = data;

          // Supposons que la première fonctionnalité est celle que vous voulez afficher
          final feature = data[0];
          final geometry = feature['geometry'];

          if (geometry != null) {
            final coordinates = geometry['coordinates'];

            if (coordinates != null && coordinates.isNotEmpty) {
              // Extraire les coordonnées pour dessiner le polygone
              List<LatLng> polygonCoords = [];
              for (var point in coordinates[0][0]) {
                polygonCoords.add(LatLng(point[1], point[0]));
              }

              // Ajouter un nouveau polygone
              polygons.clear();
              final polygon = Polygon(
                polygonId: const PolygonId('selectedPolygon'),
                points: polygonCoords,
                fillColor: Colors.green.withOpacity(0.3),
                strokeColor: Colors.green,
                strokeWidth: 2,
              );
              polygons.add(polygon);

              // Centrer la carte sur la première coordonnée
              if (polygonCoords.isNotEmpty) {
                currentLocation.value = polygonCoords[0];
              }
            } else {
              DLoader.warningSnackBar(
                title: 'Recherche',
                message: "Aucune donnee trouvé pour cet emplacement.",
              );
            }
          }
        } else {
          DLoader.warningSnackBar(
            title: 'Recherche',
            message: "Aucune donnée trouvée pour les critères spécifiés.",
          );
        }
      } else {
        print('Erreur API : ${response.statusCode}');
      }
    } catch (e) {
      print('Exception lors de la récupération des fonctionnalités : $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _initLocation() async {
    try {
      // Vérifiez les permissions
      bool _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) return;
      }

      PermissionStatus _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) return;
      }

      // Obtenez la localisation actuelle
      final userLocation = await location.getLocation();
      currentLocation.value =
          LatLng(userLocation.latitude!, userLocation.longitude!);
    } catch (e) {
      print("Erreur lors de la récupération de la localisation : $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<File?> compressImage(File file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 1024,
      minHeight: 1024,
      quality: 80, // Ajuste la qualité si besoin
    );
    if (result == null) return null;
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final compressed = File(targetPath);
    await compressed.writeAsBytes(result);
    return compressed;
  }
}

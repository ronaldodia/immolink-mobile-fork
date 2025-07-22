import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class MapController extends GetxController {
  // Position et géolocalisation
  final locationController = Location();
  Rxn<LatLng> currentPosition = Rxn<LatLng>();
  StreamSubscription<LocationData>? locationSubscription;

  // Contrôleurs de formulaire
  final TextEditingController lotController = TextEditingController();

  // Carte Google
  GoogleMapController? mapController;

  // État de la carte et sélection
  RxnDouble screenArea = RxnDouble();
  RxnString screenLotNumber = RxnString();
  RxnString screenLotissement = RxnString();
  RxnString screenMoughataa = RxnString();

  RxnString selectedMoughataa = RxnString();
  RxnString selectedLotissement = RxnString();
  RxSet<Polygon> polygons = <Polygon>{}.obs;
  RxBool isLoading = false.obs;
  RxBool isFetchingLocationDetails = false.obs;

  // Panneau d'information
  RxBool isPanelVisible = false.obs;
  RxnString panelInfo = RxnString();
  RxnString panelInfoAr = RxnString();
  RxnString panelInfoEn = RxnString();
  Rxn<Polygon> selectedPolygon = Rxn<Polygon>();

  // Données de lotissements
  RxMap<String, dynamic> lotissements = <String, dynamic>{}.obs;
  RxList<String> moughataaNames = <String>[].obs;

  // Langue
  RxBool isArabic = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialiser la carte sur Nouakchott (capitale de la Mauritanie)
    currentPosition.value = const LatLng(18.0735, -15.9582); // Nouakchott
    fetchLotissements();
    // fetchLocationUpdate(); // Désactivé au démarrage, à appeler sur action utilisateur
  }

  @override
  void onClose() {
    locationSubscription?.cancel();
    lotController.dispose();
    super.onClose();
  }

  double calculatePolygonArea(List<LatLng> coordinates) {
    if (coordinates.length < 3) {
      return 0.0;
    }
    const double radius = 6378137;
    double area = 0.0;
    for (int i = 0; i < coordinates.length; i++) {
      final LatLng p1 = coordinates[i];
      final LatLng p2 = coordinates[(i + 1) % coordinates.length];
      double lat1 = p1.latitude * math.pi / 180.0;
      double lon1 = p1.longitude * math.pi / 180.0;
      double lat2 = p2.latitude * math.pi / 180.0;
      double lon2 = p2.longitude * math.pi / 180.0;
      area += (lon2 - lon1) * (2 + math.sin(lat1) + math.sin(lat2));
    }
    area = area * radius * radius / 2.0;
    return area.abs();
  }

  Future<void> fetchLotissements() async {
    final String response =
        await rootBundle.loadString('assets/data/address.json');
    final data = await json.decode(response) as Map<String, dynamic>;
    lotissements.value = data;
    moughataaNames.value = data.keys.toList();
  }

  Future<void> fetchLocationUpdate() async {
    bool serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    var permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    locationSubscription =
        locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        currentPosition.value =
            LatLng(currentLocation.latitude!, currentLocation.longitude!);
      }
    });
  }

  Future<void> searchLot() async {
    final lot = lotController.text.toString();
    if (selectedMoughataa.value == null ||
        selectedLotissement.value == null ||
        lot.isEmpty) {
      return;
    }
    isLoading.value = true;
    final encodedLot = Uri.encodeComponent(lot);
    final encodedLotissement = Uri.encodeComponent(selectedLotissement.value!);
    final encodedMoughataa = Uri.encodeComponent(selectedMoughataa.value!);
    final url = Uri.parse(
        '${Config.baseUrlSIG}/features?lot=$encodedLot&lotissement=$encodedLotissement&moughataa=$encodedMoughataa');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final geometry = data[0]['geometry'];
        final properties = data[0]['properties'];
        if (geometry != null) {
          final coordinates = geometry['coordinates'];
          if (coordinates != null && coordinates.isNotEmpty) {
            Set<Polygon> newPolygons = {};
            List<LatLng> polygonCoords = [];
            LatLngBounds? bounds;
            int polygonIdCounter = 1;
            for (var multipolygon in coordinates) {
              for (var polygon in multipolygon) {
                for (var point in polygon) {
                  polygonCoords.add(LatLng(point[1], point[0]));
                }
                newPolygons.add(Polygon(
                  polygonId: PolygonId('polygon_$polygonIdCounter'),
                  points: polygonCoords,
                  fillColor: Colors.red.withOpacity(0.3),
                  strokeColor: Colors.red,
                  strokeWidth: 2,
                ));
                polygonIdCounter++;
                if (bounds == null) {
                  bounds = _getPolygonBounds(polygonCoords);
                } else {
                  bounds =
                      _expandBounds(bounds, _getPolygonBounds(polygonCoords));
                }
              }
            }
            polygons.value = newPolygons;
            double area = calculatePolygonArea(polygonCoords);
            String areaText = area.toStringAsFixed(2);
            panelInfo.value =
                'Lot: ${properties['l']}\nSuperficie: $areaText m²\nIndex: ${properties['i']}\nMoughataa: ${properties['moughataa']}\nLotissement: ${properties['lts']}${properties['lts']} \nAltitude: ${properties['el']}m';
            panelInfoAr.value =
                'القطعة: ${properties['l']}\nالمساحة: $areaText م²\nالمؤشر: ${properties['i']}\nالمقاطعة: ${properties['moughataa']}\nالتقسيم: ${properties['lts']} \nارتفاع: ${properties['el']} m';
            panelInfoEn.value =
                'Lot: ${properties['l']}\nArea: $areaText m²\nIndex: ${properties['i']}\nMoughataa: ${properties['moughataa']}\nLotissement: ${properties['lts']}${properties['lts']} \nAltitude: ${properties['el']}m';
            screenArea.value = area;
            screenLotissement.value = properties['lts'];
            screenLotNumber.value = properties['l'];
            screenMoughataa.value = properties['moughataa'];
            isPanelVisible.value = true;
            if (bounds != null && mapController != null) {
              mapController!
                  .animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
            }
          }
        }
      } else {
        Get.snackbar('Erreur', 'Aucune donnée trouvée pour le lot spécifié.');
      }
    } else {
      Get.snackbar('Erreur', 'Erreur lors de la récupération des données.');
    }
    isLoading.value = false;
  }

  LatLngBounds _getPolygonBounds(List<LatLng> polygonCoords) {
    double minLat = polygonCoords.first.latitude;
    double maxLat = polygonCoords.first.latitude;
    double minLng = polygonCoords.first.longitude;
    double maxLng = polygonCoords.first.longitude;
    for (LatLng coord in polygonCoords) {
      if (coord.latitude < minLat) minLat = coord.latitude;
      if (coord.latitude > maxLat) maxLat = coord.latitude;
      if (coord.longitude < minLng) minLng = coord.longitude;
      if (coord.longitude > maxLng) maxLng = coord.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  LatLngBounds _expandBounds(LatLngBounds bounds1, LatLngBounds bounds2) {
    double south = bounds1.southwest.latitude < bounds2.southwest.latitude
        ? bounds1.southwest.latitude
        : bounds2.southwest.latitude;
    double west = bounds1.southwest.longitude < bounds2.southwest.longitude
        ? bounds1.southwest.longitude
        : bounds2.southwest.longitude;
    double north = bounds1.northeast.latitude > bounds2.northeast.latitude
        ? bounds1.northeast.latitude
        : bounds2.northeast.latitude;
    double east = bounds1.northeast.longitude > bounds2.northeast.longitude
        ? bounds1.northeast.longitude
        : bounds2.northeast.longitude;
    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  Future<void> fetchLocationDetails(LatLng position) async {
    isFetchingLocationDetails.value = true;
    isPanelVisible.value = false;
    final url = Uri.parse(
        '${Config.baseUrlSIG}/location?longitude=${position.longitude}&latitude=${position.latitude}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final properties = data[0]['properties'];
        final geometry = data[0]['geometry'];
        if (geometry != null) {
          final coordinates = geometry['coordinates'];
          if (coordinates != null && coordinates.isNotEmpty) {
            Set<Polygon> newPolygons = {};
            List<LatLng> polygonCoords = [];
            for (var point in coordinates[0][0]) {
              polygonCoords.add(LatLng(point[1], point[0]));
            }
            final polygon = Polygon(
              polygonId: const PolygonId('selectedPolygon'),
              points: polygonCoords,
              fillColor: Colors.red.withOpacity(0.3),
              strokeColor: Colors.red,
              strokeWidth: 2,
            );
            newPolygons.add(polygon);
            double area = calculatePolygonArea(polygonCoords);
            String areaText = area.toStringAsFixed(2);
            polygons.value = newPolygons;
            selectedPolygon.value = polygon;
            panelInfo.value =
                'Lot: ${properties['l']}\nSuperficie: $areaText m²\nIndex: ${properties['i']}\nMoughataa: ${properties['moughataa']}\nLotissement: ${properties['lts']}\nAltitude: ${properties['el']} m';
            panelInfoAr.value =
                'القطعة: ${properties['l']}\nالمساحة: $areaText م²\nالمؤشر: ${properties['i']}\nالمقاطعة: ${properties['moughataa']}\nالتقسيم: ${properties['lts']} \nارتفاع: ${properties['el']} m';
            panelInfoEn.value =
                'Lot: ${properties['l']}\nArea: $areaText m²\nIndex: ${properties['i']}\nMoughataa: ${properties['moughataa']}\nLotissement: ${properties['lts']} \nAltitude: ${properties['el']}m';
            screenArea.value = area;
            screenLotissement.value = properties['lts'];
            screenLotNumber.value = properties['l'];
            screenMoughataa.value = properties['moughataa'];
            isPanelVisible.value = true;
          }
        }
      } else {
        Get.snackbar(
            'Erreur', 'Aucune donnée trouvée pour l\'emplacement spécifié.');
      }
    } else {
      Get.snackbar('Erreur',
          'Erreur lors de la récupération des détails de l\'emplacement.');
    }
    isFetchingLocationDetails.value = false;
  }

  void resetPanel() {
    isPanelVisible.value = false;
    selectedPolygon.value = null;
  }

  /// Appeler cette méthode pour activer la géolocalisation utilisateur (ex: bouton)
  Future<void> centerOnUserLocation() async {
    bool serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    var permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    final location = await locationController.getLocation();
    if (location.latitude != null && location.longitude != null) {
      currentPosition.value = LatLng(location.latitude!, location.longitude!);
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(currentPosition.value!),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:immolink_mobile/utils/config.dart';

class MapController extends GetxController {
  static const googlePlex = LatLng(-15.9597407, 18.0780228);
  final locationController = Location();
  Rx<LatLng?> currentPosition = Rx<LatLng?>(null);
  Rx<Set<Polygon>> polygons = Rx<Set<Polygon>>({});
  RxBool isLoading = RxBool(false);
  RxBool isFetchingLocationDetails = RxBool(false);

  RxBool isPanelVisible = RxBool(false);
  String? panelInfo;
  String? panelInfoAr ;
  String? panelInfoEn;
  Polygon? selectedPolygon;

  RxMap<String, dynamic> lotissements = RxMap<String, dynamic>({});
  RxList<String> moughataaNames = RxList<String>([]);
  RxBool isArabic = RxBool(false);

  @override
  void onInit() {
    super.onInit();
    fetchLocationUpdate();
    fetchLotissements();
  }

  @override
  void onClose() {
    super.onClose();
  }

  double calculatePolygonArea(List<LatLng> coordinates) {
    if (coordinates.length < 3) {
      return 0.0;
    }

    const double radius = 6378137; // Rayon de la Terre en mètres
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
    return area.abs(); // Retourne la valeur absolue de l'aire
  }

  Future<void> fetchLotissements() async {
    final String response =
    await rootBundle.loadString('assets/data/address.json');
    final data = json.decode(response) as Map<String, dynamic>;
    lotissements.value = data;
    moughataaNames.value = lotissements.keys.toList();
  }

  Future<void> fetchLocationUpdate() async {
    bool serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) {
        Get.snackbar(
          'Erreur',
          'Les services de localisation sont désactivés',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    var permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        Get.snackbar(
          'Permission refusée',
          'Veuillez accorder la permission de localisation pour utiliser la carte',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    try {
      locationController.onLocationChanged.listen((currentLocation) {
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          currentPosition.value = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        }
      });
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'obtenir la localisation : ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> searchLot(String lot, String? selectedMoughataa, String? selectedLotissement) async {
    if (selectedMoughataa == null || selectedLotissement == null || lot.isEmpty) {
      return;
    }

    isLoading.value = true;

    final encodedLot = Uri.encodeComponent(lot);
    final encodedLotissement = Uri.encodeComponent(selectedLotissement!);
    final encodedMoughataa = Uri.encodeComponent(selectedMoughataa!);

    final url = Uri.parse(
        '${Config.baseUrlSIG}/features?lot=$encodedLot&lotissement=$encodedLotissement&moughataa=$encodedMoughataa');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final geometry = data[0]['geometry'];
        final properties = data[0]['properties']; // Get properties for the lot
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
                  polygonId: PolygonId('polygon_$polygonIdCounter'),
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
            String areaText = area.toStringAsFixed(2); // Format area

            panelInfo =
            'Lot: ${properties['l']}\nSuperficie: $areaText m²\nIndex: ${properties['i']}\nMoughataa: ${properties['moughataa']}\nLotissement: ${properties['lts']}';
            panelInfoAr =
            'القطعة: ${properties['l']}\nالمساحة: $areaText م²\nالمؤشر: ${properties['i']}\nالمقاطعة: ${properties['moughataa']}\nالتقسيم: ${properties['lts']}';
            panelInfoEn =
            'Lot: ${properties['l']}\nArea: $areaText m²\nIndex: ${properties['i']}\nMoughataa: ${properties['moughataa']}\nLotissement: ${properties['lts']}';

            isPanelVisible.value = true; // Show the panel with lot info

            if (bounds != null) {
              // Trigger camera update with new bounds here
            }
          }
        }
      } else {
        // Show Snackbar for no data found
      }
    } else {
      // Show Snackbar for error fetching data
    }

    isLoading.value = false;
  }

  LatLngBounds _getPolygonBounds(List<LatLng> polygonCoords) {
    double minLat = polygonCoords.first.latitude;
    double maxLat = polygonCoords.first.latitude;
    double minLng = polygonCoords.first.longitude;
    double maxLng = polygonCoords.first.longitude;

    for (LatLng coord in polygonCoords) {
      if (coord.latitude < minLat) {
        minLat = coord.latitude;
      }
      if (coord.latitude > maxLat) {
        maxLat = coord.latitude;
      }
      if (coord.longitude < minLng) {
        minLng = coord.longitude;
      }
      if (coord.longitude > maxLng) {
        maxLng = coord.longitude;
      }
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
    isPanelVisible.value = false; // Hide the panel before fetching new data

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
            LatLngBounds? bounds;

            int polygonIdCounter = 1;
            for (var multipolygon in coordinates) {
              for (var polygon in multipolygon) {
                for (var point in polygon) {
                  polygonCoords.add(LatLng(point[1], point[0]));
                }
                newPolygons.add(Polygon(
                  polygonId: PolygonId('polygon_$polygonIdCounter'),
                  points: polygonCoords,
                  fillColor: Colors.blue.withOpacity(0.3),
                  strokeColor: Colors.blue,
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
            String areaText = area.toStringAsFixed(2); // Format area

            panelInfo =
            'Location: ${properties['location']}\nArea: $areaText m²\nIndex: ${properties['index']}\nRegion: ${properties['region']}\nSubdivision: ${properties['subdivision']}';
            panelInfoAr =
            'الموقع: ${properties['location']}\nالمساحة: $areaText م²\nالمؤشر: ${properties['index']}\nالمنطقة: ${properties['region']}\nالتقسيم: ${properties['subdivision']}';
            panelInfoEn =
            'Location: ${properties['location']}\nArea: $areaText m²\nIndex: ${properties['index']}\nRegion: ${properties['region']}\nSubdivision: ${properties['subdivision']}';

            isPanelVisible.value = true; // Show the panel with location info

            if (bounds != null) {
              // Trigger camera update with new bounds here
            }
          }
        }
      } else {
        // Show Snackbar for no data found
      }
    } else {
      // Show Snackbar for error fetching data
    }

    isFetchingLocationDetails.value = false;
  }
}


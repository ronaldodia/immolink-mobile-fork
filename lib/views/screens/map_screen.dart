import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const googlePlex = LatLng(-15.9597407, 18.0780228);
  final locationController = Location();
  LatLng? currentPosition;
  StreamSubscription<LocationData>? locationSubscription;
  final TextEditingController lotController = TextEditingController();
  GoogleMapController? mapController;

  String? selectedMoughataa;
  String? selectedLotissement;
  Set<Polygon> polygons = {};

  Map<String, List<String>> lotissements = {
    "Plan_Arafatt": [
      "11_A",
      "11_B",
      "12_Arafatt",
      "13_Arafatt",
      "15_Arafatt",
      "5_Arafatt",
      "6_Arafatt",
      "A_Carrefour",
      "B_Carrefour",
      "Cimetiere",
      "Complement_EXT_ARAFATT",
      "C_CARREFOUR",
      "C_EXT_carrefour_phase_2",
      "D_Carrefour",
      "Extension Secteur A",
      "E_Carrefour",
      "F_Modifie_Partie_A",
      "Secteur 9",
      "Secteur_1",
      "Secteur_2_3",
      "Secteur_3_Extension",
      "Secteur_4_Extension",
      "secteur_4",
      "Secteur_5_EXT",
      "Secteur_6_Extension",
      "Secteur_7",
      "Secteur_8",
      "Zone_Carrefour_Ext"
    ],
    // Ajoutez les autres moughataa ici...
    "plan_Ksar": [
      "Centrale_Chinoise",
      "Complement Madrid",
      "C_5",
      "C_6",
      "Douane",
      "Gare routiere KSAR",
      "GBM",
      "Ksar_A1_A5_ET_B1_B4",
      "Ksar_Ancien",
      "Ksar_Ouest",
      "Ksar_Socomatale",
      "Liaison_F_nord_Ksar_Ouest",
      "liaison_ksar_extension",
      "SOCOGIM_KSAR",
      "Zone Entrepot et Commerciale"
    ],
    // Ajoutez les autres moughataa ici...
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) async => await fetchLocationUpdate());
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
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
        if (mounted) {
          setState(() {
            currentPosition =
                LatLng(currentLocation.latitude!, currentLocation.longitude!);
          });
        }
      }
    });
  }

  Future<void> searchLot() async {
    final lot = lotController.text;
    if (selectedMoughataa == null ||
        selectedLotissement == null ||
        lot.isEmpty) {
      // Afficher un message d'erreur ou retourner
      return;
    }

    print('lot: $lot, lotissement: $selectedLotissement, et moughataa: $selectedMoughataa'); 
    final url = Uri.parse(
        'https://gis.digissimmo.org/api/features?lot=$lot&lotissement=$selectedLotissement&moughataa=$selectedMoughataa');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final geometry = data[0]['geometry'];
        if (geometry != null) {
          final coordinates = geometry['coordinates'];
          if (coordinates != null && coordinates.isNotEmpty) {
            Set<Polygon> newPolygons = {};
            LatLngBounds? bounds;

            int polygonIdCounter = 1;
            for (var multipolygon in coordinates) {
              for (var polygon in multipolygon) {
                List<LatLng> polygonCoords = [];
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
                  bounds = _expandBounds(bounds, _getPolygonBounds(polygonCoords));
                }
              }
            }
            setState(() {
              polygons = newPolygons;
            });

            if (bounds != null) {
              mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
            }

            return;
          }
        }
      }
      // Handle no data found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune donnée trouvée pour le lot spécifié.')),
      );
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la récupération des données.')),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Moughataa'),
              value: selectedMoughataa,
              onChanged: (value) {
                setState(() {
                  selectedMoughataa = value;
                  selectedLotissement =
                      null; // Reset lotissement when moughataa changes
                });
              },
              items: lotissements.keys.map((moughataa) {
                return DropdownMenuItem(
                  value: moughataa,
                  child: Text(moughataa),
                );
              }).toList(),
            ),
          ),
          if (selectedMoughataa != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Lotissement'),
                value: selectedLotissement,
                onChanged: (value) {
                  setState(() {
                    selectedLotissement = value;
                  });
                },
                items: lotissements[selectedMoughataa]!.map((lotissement) {
                  return DropdownMenuItem(
                    value: lotissement,
                    child: Text(lotissement),
                  );
                }).toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: lotController,
              decoration: const InputDecoration(labelText: 'Numéro de Lot'),
            ),
          ),
          ElevatedButton(
            onPressed: searchLot,
            child: const Text('Rechercher'),
          ),
          Expanded(
            child: currentPosition == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                    initialCameraPosition:
                        CameraPosition(target: currentPosition!, zoom: 20),
                    mapType: MapType.satellite,
                    myLocationEnabled: true,
                    polygons: polygons,
                  ),
          ),
        ],
      ),
    );
  }
}

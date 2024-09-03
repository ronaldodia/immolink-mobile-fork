import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin<MapScreen> {
  static const googlePlex = LatLng(-15.9597407, 18.0780228);
  final locationController = Location();
  LatLng? currentPosition;
  StreamSubscription<LocationData>? locationSubscription;
  final TextEditingController lotController = TextEditingController();
  GoogleMapController? mapController;

  String? selectedMoughataa;
  String? selectedLotissement;
  Set<Polygon> polygons = {};
  bool isLoading = false;
  bool isFetchingLocationDetails = false;

  // New variables for selected location info panel
  bool isPanelVisible = false;
  String? panelInfo;
  String? panelInfoAr;
  String? panelInfoEn;
  Polygon? selectedPolygon;

  Map<String, dynamic> lotissements = {};
  List<String> moughataaNames = [];
  bool isArabic = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        ?.addPostFrameCallback((_) async => await fetchLocationUpdate());
    fetchLotissements();
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
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
    final data = await json.decode(response) as Map<String, dynamic>;
    setState(() {
      // lotissements = data.map((key, value) => MapEntry(key, List<String>.from(value)));
      lotissements = data;
      moughataaNames = lotissements.keys.toList();
    });
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
    final lot = lotController.text.toString();
    if (selectedMoughataa == null ||
        selectedLotissement == null ||
        lot.isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final encodedLot = Uri.encodeComponent(lot);
    final encodedLotissement = Uri.encodeComponent(selectedLotissement!);
    final encodedMoughataa = Uri.encodeComponent(selectedMoughataa!);
    print(
        'lot: ${encodedLot}, lotissement: ${encodedLotissement}, :moughataa: ${encodedMoughataa}');

    final url = Uri.parse(
        '${Config.baseUrlSIG}/features?lot=$encodedLot&lotissement=$encodedLotissement&moughataa=$encodedMoughataa');
    print(url);
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
            setState(() {
              polygons = newPolygons;
              double area = calculatePolygonArea(polygonCoords);
              String areaText = area.toStringAsFixed(2); // Format area

              panelInfo =
                  'Lot: ${properties['l']}\nSuperficie: $areaText m²\nIndex: ${properties['i']}\nMoughataa: ${properties['moughataa']}\nLotissement: ${properties['lts']}';
              panelInfoAr =
                  'القطعة: ${properties['l']}\nالمساحة: $areaText م²\nالمؤشر: ${properties['i']}\nالمقاطعة: ${properties['moughataa']}\nالتقسيم: ${properties['lts']}';
              panelInfoEn =
                  'Lot: ${properties['l']}\nArea: $areaText m²\nIndex: ${properties['i']}\nMoughataa: ${properties['moughataa']}\nLotissement: ${properties['lts']}';

              isPanelVisible = true; // Show the panel with lot info
            });

            if (bounds != null) {
              mapController
                  ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
            }
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Aucune donnée trouvée pour le lot spécifié.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de la récupération des données.')),
      );
    }

    setState(() {
      isLoading = false;
    });
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

  // New method to fetch location details on map tap
  Future<void> fetchLocationDetails(LatLng position) async {
    setState(() {
      isFetchingLocationDetails = true;
      isPanelVisible = false; // Hide the panel before fetching new data
    });

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
            String areaText =
                area.toStringAsFixed(2); // Convert to hectares and format

            setState(() {
              polygons = newPolygons;
              selectedPolygon = polygon;
              panelInfo =
                  'Lot: ${properties['l']}\nSuperficie: $areaText m²\nIndex: ${properties['i']}\nMoughataa: ${properties['moughataa']}\nLotissement: ${properties['lts']}';
              panelInfoAr =
                  'القطعة: ${properties['l']}\nالمساحة: $areaText م²\nالمؤشر: ${properties['i']}\nالمقاطعة: ${properties['moughataa']}\nالتقسيم: ${properties['lts']}';
              panelInfoEn =
                  'Lot: ${properties['l']}\nArea: $areaText m²\nIndex: ${properties['i']}\nMoughataa: ${properties['moughataa']}\nLotissement: ${properties['lts']}';

              isPanelVisible = true;
            });
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Aucune donnée trouvée pour l\'emplacement spécifié.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Erreur lors de la récupération des détails de l\'emplacement.')),
      );
    }

    setState(() {
      isFetchingLocationDetails = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double screenWidth = MediaQuery.of(context).size.width;

    // Adjusted spacing for responsive design
    double formFieldSpacing = screenWidth * 0.03;
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: currentPosition == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    mapToolbarEnabled: false,
                    myLocationButtonEnabled: false,
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                    initialCameraPosition:
                        CameraPosition(target: currentPosition!, zoom: 18),
                    mapType: MapType.satellite,
                    myLocationEnabled:
                        true, // Disabled here to customize button
                    polygons: polygons,
                    onTap: (position) async {
                      setState(() {
                        isPanelVisible =
                            false; // Hide the panel before fetching new data
                      });
                      await fetchLocationDetails(position);
                    },
                  ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (isFetchingLocationDetails)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            top: 100,
            left: 10,
            right: 10,
            child: SingleChildScrollView(
              child: Card(
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context)!.moughataa),
                              value: selectedMoughataa,
                              onChanged: (value) {
                                setState(() {
                                  selectedMoughataa = value;
                                  selectedLotissement = null;
                                });
                              },
                              items: moughataaNames.map((name) {
                                final arabicName =
                                    lotissements[name]['arabicName'];
                                final saxonName = lotissements[name]['name'];
                                print(
                                    'langue: ${Localizations.localeOf(context).languageCode}');
                                return DropdownMenuItem<String>(
                                  value: name,
                                  child:
                                      Text(isArabic ? arabicName : saxonName),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(width: formFieldSpacing),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .lotissement),
                              value: selectedLotissement,
                              onChanged: (value) {
                                setState(() {
                                  selectedLotissement = value;
                                });
                              },
                              items: (lotissements[selectedMoughataa]
                                          ?['lotissements'] ??
                                      [])
                                  .map<DropdownMenuItem<String>>((lot) {
                                return DropdownMenuItem<String>(
                                  value: lot,
                                  child: Text(lot),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: lotController,
                              decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context)!.lot_number),
                            ),
                          ),
                          SizedBox(width: formFieldSpacing),
                          ElevatedButton(
                            onPressed: searchLot,
                            child: isLoading
                                ? const SizedBox(
                                    width: 16.0,
                                    height: 16.0,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(AppLocalizations.of(context)!
                                    .search_button),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 5,
            child: FloatingActionButton(
              backgroundColor: Colors.white.withOpacity(0.8),
              onPressed: () async {
                if (currentPosition != null) {
                  mapController?.animateCamera(
                    CameraUpdate.newLatLng(currentPosition!),
                  );
                }
              },
              child: const Icon(
                Icons.man,
                size: 40,
                color: Colors.black,
              ),
            ),
          ),
          if (isPanelVisible)
            Positioned(
              bottom: 20,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isArabic
                                ? panelInfoAr!
                                : (Localizations.localeOf(context)
                                            .languageCode ==
                                        'en'
                                    ? panelInfoEn!
                                    : panelInfo!),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                isPanelVisible = false;
                                polygons.remove(selectedPolygon);
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Implement route functionality
                            },
                            child: const Text('Itinéraire'),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Implement route functionality
                            },
                            child: const Text('Ajouter'),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Implement route functionality
                            },
                            child: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.share)),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

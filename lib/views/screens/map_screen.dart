import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
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
  bool isLoading = false;
  bool isFetchingLocationDetails = false;

  // New variables for selected location info panel
  bool isPanelVisible = false;
  String? panelInfo;
  Polygon? selectedPolygon;

 Map<String, List<String>> lotissements = {};

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
  

  Future<void> fetchLotissements() async {
    final String response = await rootBundle.loadString('assets/data/address.json');
    final data = await json.decode(response) as Map<String, dynamic>;
    setState(() {
      lotissements = data.map((key, value) => MapEntry(key, List<String>.from(value)));
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
    final lot = lotController.text;
    if (selectedMoughataa == null ||
        selectedLotissement == null ||
        lot.isEmpty) {
      return;
    }

    setState(() {
      isLoading = true;
    });

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
                  bounds =
                      _expandBounds(bounds, _getPolygonBounds(polygonCoords));
                }
              }
            }
            setState(() {
              polygons = newPolygons;
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
        'https://gis.digissimmo.org/api/location?longitude=${position.longitude}&latitude=${position.latitude}');
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

            setState(() {
              polygons = newPolygons;
              selectedPolygon = polygon;
              panelInfo =
                  'Lot: ${properties['l']}\nIndex: ${properties['i']}\nMoughataa: ${properties['moughataa']}\nLotissement: ${properties['lts']}';
              isPanelVisible = true;
            });
          }
        }
      }
    }

    setState(() {
      isFetchingLocationDetails = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Adjusted width for responsive design
    double formFieldWidth = screenWidth * 0.45;

    // Adjusted spacing for responsive design
    double formFieldSpacing = screenWidth * 0.03;

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
          if (isPanelVisible && panelInfo != null)
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Card(
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(panelInfo!),
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
                      ElevatedButton(
                        onPressed: () {
                          // Implement route functionality
                        },
                        child: const Text('Itinéraire'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            top: 70,
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
                              decoration:
                                  const InputDecoration(labelText: 'Moughataa'),
                              value: selectedMoughataa,
                              onChanged: (value) {
                                setState(() {
                                  selectedMoughataa = value;
                                  selectedLotissement = null;
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
                          SizedBox(width: formFieldSpacing),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: const InputDecoration(
                                  labelText: 'Lotissement'),
                              value: selectedLotissement,
                              onChanged: (value) {
                                setState(() {
                                  selectedLotissement = value;
                                });
                              },
                              items: selectedMoughataa != null
                                  ? lotissements[selectedMoughataa]!
                                      .map((lotissement) {
                                      return DropdownMenuItem(
                                        value: lotissement,
                                        child: Text(lotissement),
                                      );
                                    }).toList()
                                  : [],
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
                              decoration: const InputDecoration(
                                  labelText: 'Numéro de Lot'),
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
                                : const Text('Rechercher'),
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
            top: 5,
            right: 5,
            child: FloatingActionButton(
              backgroundColor: Colors.white.withOpacity(0.3),
              onPressed: () async {
                if (currentPosition != null) {
                  mapController?.animateCamera(
                    CameraUpdate.newLatLng(currentPosition!),
                  );
                }
              },
              child: const Icon(Icons.person),
            ),
          ),
        ],
      ),
    );
  }
}

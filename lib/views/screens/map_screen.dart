import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const googlePlex = LatLng(-15.9602002, 18.0600953);
  final locationController = Location();
  LatLng? currentPosition;
  StreamSubscription<LocationData>? locationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async => await fetchLocationUpdate());
  }

  @override
  void dispose() {
    // Cancel the location subscription when the widget is disposed.
    locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPosition == null ?
      const Center(child: CircularProgressIndicator(),)
      : GoogleMap(
        initialCameraPosition: CameraPosition(target: googlePlex, zoom: 16),
        mapType: MapType.satellite,
        myLocationEnabled: currentPosition != null,
        markers: currentPosition != null
            ? {
                Marker(
                  markerId: const MarkerId('currentPosition'),
                  position: currentPosition!,
                )
              }
            : {},
      ),
    );
  }

  Future<void> fetchLocationUpdate() async {
    bool serviceEnabled;
    PermissionStatus permissionStatus;
    serviceEnabled = await locationController.serviceEnabled();

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

    locationSubscription = locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        if (mounted) {
          setState(() {
            currentPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          });
        }
      }
    });

    print(currentPosition);
  }
}

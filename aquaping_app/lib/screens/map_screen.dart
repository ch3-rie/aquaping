// lib/screens/map_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final mapController = MapController();

  LatLng userLocation = LatLng(14.5995, 120.9842);

  List<Polygon> zonePolygons = [];
  List<Map<String, dynamic>> evacCenters = [];

  LatLng? selectedLocation;
  Map<String, dynamic>? nearestEvacCenter;

  // FIX: missing variables
  Marker? nearestEvacMarker;
  List<_EvacMarker> evacMarkers = [];

  @override
  void initState() {
    super.initState();
    _locateUser();
    _loadZones();
    _loadEvacCenters();
  }

  // ------------------------------------------------------------
  // USER LOCATION
  // ------------------------------------------------------------
  Future<void> _locateUser() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }
      if (perm == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition();

      setState(() {
        userLocation = LatLng(pos.latitude, pos.longitude);
        mapController.move(userLocation, 13.0);
      });

      _highlightNearestEvac();
    } catch (_) {}
  }

  // ------------------------------------------------------------
  // ZONES
  // ------------------------------------------------------------
  Future<void> _loadZones() async {
    try {
      final res = await ApiService.getZones();
      final polygons = res["zones"] ?? [];

      List<Polygon> list = [];

      for (var zone in polygons) {
        final severity = zone["severity"] ?? "yellow";
        final geoJson = zone["polygon_geojson"];
        if (geoJson == null) continue;

        final parsed = jsonDecode(geoJson);

        if (parsed["type"] == "Polygon") {
          final coords = parsed["coordinates"][0] as List;

          final latLngs = coords.map<LatLng>((c) {
            return LatLng(
              (c[1] as num).toDouble(),
              (c[0] as num).toDouble(),
            );
          }).toList();

          list.add(
            Polygon(
              points: latLngs,
              color: _severityColor(severity).withOpacity(0.3),
              borderColor: _severityColor(severity),
              borderStrokeWidth: 2,
            ),
          );
        }
      }

      setState(() => zonePolygons = list);
    } catch (_) {}
  }

  // ------------------------------------------------------------
  // EVAC CENTERS
  // ------------------------------------------------------------
  Future<void> _loadEvacCenters() async {
    try {
      final res = await ApiService.getEvacCenters();
      final centers = res["centers"] ?? [];

      evacCenters = centers.map((c) {
        return {
          "name": c["name"],
          "address": c["address"] ?? "",
          "capacity": c["capacity"] ?? "",
          "contact": c["contact"] ?? "",
          "lat": (c["latitude"] ?? 0).toDouble(),
          "lng": (c["longitude"] ?? 0).toDouble(),
          "latitude": (c["latitude"] ?? 0).toDouble(),
          "longitude": (c["longitude"] ?? 0).toDouble(),
        };
      }).toList();

      // build markers
      evacMarkers = evacCenters.map((c) {
        return _EvacMarker(
          key: c,
          point: LatLng(c["lat"], c["lng"]),
        );
      }).toList();

      setState(() {});
      _highlightNearestEvac();
    } catch (_) {}
  }

  // ------------------------------------------------------------
  // NEAREST EVAC LOGIC
  // ------------------------------------------------------------
  void _highlightNearestEvac() {
    if (evacCenters.isEmpty) return;

    final Distance dist = Distance();

    Map<String, dynamic> nearest = evacCenters.first;
    double minDist = dist(userLocation, LatLng(nearest["lat"], nearest["lng"]));

    for (var c in evacCenters) {
      final d = dist(userLocation, LatLng(c["lat"], c["lng"]));
      if (d < minDist) {
        minDist = d;
        nearest = c;
      }
    }

    nearestEvacCenter = nearest;

    nearestEvacMarker = Marker(
      point: LatLng(nearest["lat"], nearest["lng"]),
      width: 60,
      height: 60,
      child: const Icon(Icons.star_rate, color: Colors.orange, size: 40),
    );

    setState(() {});
  }

  Color _severityColor(String s) {
    switch (s) {
      case "yellow":
        return const Color(0xFFFFD54F);
      case "orange":
        return const Color(0xFFFF8A65);
      case "red":
        return const Color(0xFFE53935);
      default:
        return Colors.blueGrey;
    }
  }

  // ------------------------------------------------------------
  // EVAC POPUP
  // ------------------------------------------------------------
  void _openEvacCenterInfo(Map center) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(center["name"],
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text("Address: ${center["address"]}"),
              Text("Capacity: ${center["capacity"]}"),
              Text("Contact: ${center["contact"]}"),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text("View on Map"),
                onPressed: () {
                  mapController.move(
                    LatLng(center["latitude"], center["longitude"]),
                    17,
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flood Map")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: userLocation,
              initialZoom: 13,
              minZoom: 3,
              maxZoom: 19,
              onTap: (tapPos, latlng) {
                setState(() => selectedLocation = latlng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png",
                subdomains: const ["a", "b", "c"],
              ),

              PolygonLayer(polygons: zonePolygons),

              MarkerLayer(
                markers: [
                  // user location
                  Marker(
                    point: userLocation,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.person_pin_circle,
                        color: Colors.blue, size: 45),
                  ),

                  if (nearestEvacMarker != null) nearestEvacMarker!,

                  ...evacMarkers.map((m) {
                    return Marker(
                      point: m.point,
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _openEvacCenterInfo(m.key),
                        child: const Icon(Icons.location_on,
                            color: Colors.green, size: 36),
                      ),
                    );
                  }),

                  if (selectedLocation != null)
                    Marker(
                      point: selectedLocation!,
                      width: 30,
                      height: 30,
                      child: const Icon(Icons.check_circle,
                          color: Colors.deepPurple, size: 30),
                    )
                ],
              ),
            ],
          ),

          // Zoom +
          Positioned(
            right: 15,
            bottom: 150,
            child: FloatingActionButton.small(
              onPressed: () {
                mapController.move(
                  mapController.camera.center,
                  mapController.camera.zoom + 1,
                );
              },
              child: const Icon(Icons.add),
            ),
          ),

          // Zoom -
          Positioned(
            right: 15,
            bottom: 100,
            child: FloatingActionButton.small(
              onPressed: () {
                mapController.move(
                  mapController.camera.center,
                  mapController.camera.zoom - 1,
                );
              },
              child: const Icon(Icons.remove),
            ),
          ),

          // Recenter
          Positioned(
            right: 15,
            bottom: 50,
            child: FloatingActionButton.small(
              backgroundColor: Colors.blue,
              child: const Icon(Icons.my_location, color: Colors.white),
              onPressed: () {
                mapController.move(userLocation, 15);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// helper class for evacMarkers
class _EvacMarker {
  final Map key;
  final LatLng point;
  _EvacMarker({required this.key, required this.point});
}

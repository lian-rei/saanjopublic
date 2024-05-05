import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:saanjologin/terminal_list.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Marker> markers = [];
  Future<Position>? _positionFuture;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _positionFuture = Future.value(Position.fromMap({
        'latitude': 14.808227,
        'longitude': 121.047535,
        })
      );
    } else if (Platform.isAndroid) {
      _positionFuture = _determinePosition();
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
      future: _positionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final position = snapshot.data!;
          return FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(position.latitude, position.longitude),
              initialZoom: 20.2,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              LocationMarkerLayer(position: LocationMarkerPosition(
                latitude: terminals[0].latitude,
                longitude: terminals[0].longitude,
                accuracy: 5
                ),
                style: LocationMarkerStyle(
                  marker: const DefaultLocationMarker(
                    child: Icon(
                      Icons.ac_unit_rounded,
                      color: Colors.blue,
                    ),
                  ),
                  markerSize: const Size(20,20)
                ),
                ),
                LocationMarkerLayer(position: LocationMarkerPosition(
                latitude: terminals[1].latitude,
                longitude: terminals[1].longitude,
                accuracy: 5
                ), style: LocationMarkerStyle(
                  markerSize: Size(5,5),
                  showHeadingSector: false,
                  showAccuracyCircle: false,
                  marker: const DefaultLocationMarker(
                    color: Colors.transparent,
                    child: Icon(
                      Icons.ac_unit_rounded,
                      color: Colors.black26
                    )
                  )
                )  ),
              CurrentLocationLayer(
                alignPositionOnUpdate: AlignOnUpdate.always,
                alignDirectionOnUpdate: AlignOnUpdate.always,
                style: LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(
                      Icons.navigation,
                      color: Colors.white,
                    ),
                  ),
                  markerSize: const Size(40, 40),
                  markerDirection: MarkerDirection.heading,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
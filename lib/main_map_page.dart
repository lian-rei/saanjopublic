
import 'dart:io' show Platform;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;
import 'terminal_list.dart';
class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}


  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
  final String mapboxApiKey = 'pk.eyJ1IjoicmVpamkyMDAyIiwiYSI6ImNsdnV6c2hhZzFxZTAybG1oMzJoeDNtOGQifQ.0hCQ02IhCilBVh-DhFDioQ';
  final String url = 'https://api.mapbox.com/directions/v5/mapbox/driving/$start;$end?geometries=geojson&access_token=$mapboxApiKey';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List<LatLng> points = [];
    for (final feature in data['routes'][0]['geometry']['coordinates'] as List) {
      points.add(LatLng(feature[1], feature[0]));
    }
    return points;
  } else {
    print('Error: ${response.body}');
    throw Exception('Failed to load route');
  }
}


class _MapPageState extends State<MapPage> {
  List<Marker> markers = [];
  Future<Position>? _positionFuture;
  List<LatLng> routePoints = [];

 

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _positionFuture = Future.value(Position.fromMap({
        'latitude': 14.808227,
        'longitude': 121.047535,
      }));
    } else if (Platform.isAndroid) {
      _positionFuture = _determinePosition();
    };
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Page'),
      ),
      body: FutureBuilder<Position>(
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
                initialZoom: 15.0,
              ),
               children: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/reiji2002/clvxk6ihd011v01pccts41fc7/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoicmVpamkyMDAyIiwiYSI6ImNsdnV6b2Q5YzFzMjgya214ZW5rZnFwZTEifQ.pEJZ0EOKW3tMR0wxmr--cQ',
                      additionalOptions: {
                        'accessToken':'?access_token=pk.eyJ1IjoicmVpamkyMDAyIiwiYSI6ImNsdnV6c2hhZzFxZTAybG1oMzJoeDNtOGQifQ.0hCQ02IhCilBVh-DhFDioQ',
                        'id': 'mapbox.mapbox-streets-v8'
                      },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(terminals[1].latitude, terminals[1].longitude),
                      width: 150,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.emoji_transportation_rounded,
                            color: Color.fromARGB(255, 187, 121, 172),
                            size: 40),
                          Positioned(
                            bottom: 22,
                            child: Text(
                              'Tungko - San Jose \n Jeepney Terminal',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                ),
                              
                            ),
                          ),
                        ],
                      ),
                    ),
                    Marker(
                      point: LatLng(terminals[0].latitude, terminals[0].longitude),
                      width: 150,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.emoji_transportation_rounded,
                            color: Color.fromARGB(255, 230, 198, 56),
                            size: 40),
                          Positioned(
                            bottom: 22,
                            child: Text(
                              'Muzon - Novaliches \n Jeepney Terminal',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                ),
                              
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            );
          }
        },
      ),
    );
  }
}
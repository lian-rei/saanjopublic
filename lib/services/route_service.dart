import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapbox_gl/mapbox_gl.dart';

class RouteService {
  final String accessToken = 'pk.eyJ1IjoicmVpamkyMDAyIiwiYSI6ImNsdnV6c2hhZzFxZTAybG1oMzJoeDNtOGQifQ.0hCQ02IhCilBVh-DhFDioQ';

  Future<List<LatLng>> getRoute(List<LatLng> points) async {
    final coordinates = points.map((point) => '${point.longitude},${point.latitude}').join(';');
    final url = 'https://api.mapbox.com/directions/v5/mapbox/driving/$coordinates?access_token=$accessToken&geometries=geojson&overview=full';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final route = data['routes'][0]['geometry']['coordinates'];
      return route.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList();
    } else {
      throw Exception('Failed to load route');
    }
  }

  Future<List<LatLng>> getWalkingRoute(LatLng start, LatLng end) async {
    final coordinates = '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';
    final url = 'https://api.mapbox.com/directions/v5/mapbox/walking/$coordinates?access_token=$accessToken&geometries=geojson&overview=full';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final route = data['routes'][0]['geometry']['coordinates'];
      return route.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList();
    } else {
      throw Exception('Failed to load walking route');
    }
  }

  Future<List<LatLng>> getTerminalRoute(LatLng start, LatLng end) async {
    final coordinates = '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';
    final url = 'https://api.mapbox.com/directions/v5/mapbox/driving/$coordinates?access_token=$accessToken&geometries=geojson&overview=full';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final route = data['routes'][0]['geometry']['coordinates'];
      return route.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList();
    } else {
      throw Exception('Failed to load terminal route');
    }
  }
}

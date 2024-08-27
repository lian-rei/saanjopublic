import 'package:flutter/foundation.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'location_service.dart';
import 'route_service.dart';
import '../models/terminal.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:geolocator/geolocator.dart';

class MapController extends ChangeNotifier {
  MapboxMapController? mapController;
  final LocationService locationService = LocationService();
  final RouteService routeService = RouteService();
  Future<Position>? positionFuture;
  bool styleLoaded = false;
  bool isRoutingEnabled = false;
  bool waitingForSecondPoint = false;
  Map<String, Terminal> terminalMarkers = {};
  Terminal? selectedTerminal;
  List<Line> currentPolylines = [];
  LatLng? startPoint;
  LatLng? endPoint;

  void clearSelectedTerminal() {
    selectedTerminal = null;
    notifyListeners();
  }

  void initializeLocationService() {
    if (kIsWeb) {
      positionFuture = Future.value(Position.fromMap({
        'latitude': 14.808227,
        'longitude': 121.047535,
      }));
    } else {
      positionFuture = locationService.determinePosition();
    }
  }

  void onMapCreated(MapboxMapController controller) {
    mapController = controller;
    // We rely on the onStyleLoaded callback instead of checking a property
  }

  void onStyleLoaded() {
    styleLoaded = true;
    _addMarkers();
  }

  Future<void> _addMarkers() async {
    if (mapController == null || !styleLoaded) return;

    for (var terminal in terminals) {
      var firstPoint = terminal.points.first;
      try {
        final ByteData bytes = await rootBundle.load(terminal.iconImage);
        final Uint8List list = bytes.buffer.asUint8List();
        final img.Image image = img.decodeImage(list)!;
        final Uint8List markerImage = Uint8List.fromList(img.encodePng(image));

        await mapController!.addImage(terminal.name, markerImage);
        var symbol = await mapController!.addSymbol(
          SymbolOptions(
            geometry: firstPoint,
            iconImage: terminal.name,
            iconSize: 0.07,
            iconHaloWidth: 100,
            iconHaloBlur: 0.2,
            iconHaloColor: "#000000",
            textField: terminal.name,
            textOffset: Offset(0, 2.5),
            textSize: 12.0,
            textHaloColor: "#FFFFFF",
            textHaloWidth: 0.5,
          ),
        );
        terminalMarkers[symbol.id] = terminal;
      } catch (e) {
        print('Error adding symbol for ${terminal.name} at ($firstPoint): $e');
      }
    }

    mapController?.onSymbolTapped.add(_onSymbolTapped);
  }

  void _onSymbolTapped(Symbol symbol) async {
    selectedTerminal = terminalMarkers[symbol.id];

    if (selectedTerminal != null) {
      try {
        List<LatLng> routePoints = await routeService.getRoute(selectedTerminal!.points);
        _clearCurrentPolylines();
        if (mapController != null) {
          Line line = await mapController!.addLine(
            LineOptions(
              geometry: routePoints,
              lineColor: selectedTerminal!.routeColor,
              lineWidth: 5.0,
              lineOpacity: 0.8,
            ),
          );
          currentPolylines.add(line);
        }
      } catch (e) {
        print('Error adding polyline for ${selectedTerminal!.name}: $e');
      }
    }
  }

  void _clearCurrentPolylines() {
    mapController?.clearLines();
    currentPolylines.clear();
  }

  void onMapClick(LatLng coordinates) async {
    if (!isRoutingEnabled) return;

    if (startPoint == null) {
      startPoint = coordinates;
      await _addStartPointMarker();  // Ensure async operation is awaited
    } else if (endPoint == null) {
      endPoint = coordinates;
      await _addEndPointMarker();  // Ensure async operation is awaited
      await _calculateRoute();  // Ensure async operation is awaited
    }
  }

  Future<void> _addStartPointMarker() async {
    if (mapController != null && startPoint != null) {
      await mapController!.addSymbol(
        SymbolOptions(
          geometry: startPoint!,
          iconImage: "start-icon",
          iconSize: 0.07,
        ),
      );
    }
  }

  Future<void> _addEndPointMarker() async {
    if (mapController != null && endPoint != null) {
      await mapController!.addSymbol(
        SymbolOptions(
          geometry: endPoint!,
          iconImage: "end-icon",
          iconSize: 0.07,
        ),
      );
    }
  }

  Future<void> _calculateRoute() async {
    if (startPoint != null && endPoint != null) {
      LatLng nearestStartTerminal = _findNearestTerminal(startPoint!);
      LatLng nearestEndTerminal = _findNearestTerminal(endPoint!);

      List<LatLng> walkingRoute1 = await routeService.getWalkingRoute(startPoint!, nearestStartTerminal);
      List<LatLng> terminalRoute = await routeService.getTerminalRoute(nearestStartTerminal, nearestEndTerminal);
      List<LatLng> walkingRoute2 = await routeService.getWalkingRoute(nearestEndTerminal, endPoint!);

      await _drawRoute(walkingRoute1, terminalRoute, walkingRoute2);  // Ensure async operation is awaited
    }
  }

  LatLng _findNearestTerminal(LatLng point) {
    double minDistance = double.infinity;
    LatLng nearestTerminal = terminals.first.points.first;

    for (var terminal in terminals) {
      for (var terminalPoint in terminal.points) {
        double distance = _calculateDistance(point, terminalPoint);
        if (distance < minDistance) {
          minDistance = distance;
          nearestTerminal = terminalPoint;
        }
      }
    }

    return nearestTerminal;
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    return (p1.latitude - p2.latitude).abs() + (p2.longitude - p1.longitude).abs();
  }

  Future<void> _drawRoute(List<LatLng> route1, List<LatLng> terminalRoute, List<LatLng> route2) async {
    if (mapController != null) {
      await mapController!.addLine(
        LineOptions(
          geometry: route1,
          lineColor: "#ff0000",
          lineWidth: 4.0,
          lineOpacity: 0.7,
        ),
      );

      await mapController!.addLine(
        LineOptions(
          geometry: terminalRoute,
          lineColor: "#00ff00",
          lineWidth: 4.0,
          lineOpacity: 0.7,
        ),
      );

      await mapController!.addLine(
        LineOptions(
          geometry: route2,
          lineColor: "#0000ff",
          lineWidth: 4.0,
          lineOpacity: 0.7,
        ),
      );
    }
  }

  void enableRouting() {
    isRoutingEnabled = true;
    notifyListeners();
  }
}

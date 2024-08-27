import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import '../services/map_controller.dart';
import '../widgets/map_widgets.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _mapController.initializeLocationService();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
      future: _mapController.positionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MapLoadingIndicator(); // Custom loading indicator
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching location'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('Location data not available'));
        }

        Position position = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text('Map Routing'),
            actions: [
              MapActionButton( // Custom action button for routing
                onPressed: _mapController.enableRouting,
              ),
            ],
          ),
          body: Stack(
            children: [
              MapboxMap(
                accessToken: 'pk.eyJ1IjoicmVpamkyMDAyIiwiYSI6ImNsdnV6c2hhZzFxZTAybG1oMzJoeDNtOGQifQ.0hCQ02IhCilBVh-DhFDioQ',
                onMapCreated: _mapController.onMapCreated,
                onStyleLoadedCallback: _mapController.onStyleLoaded,
                initialCameraPosition: CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 14.0,
                ),
                onMapClick: ((point, coordinates) => _mapController.onMapClick(coordinates)),
                myLocationEnabled: true,
                myLocationTrackingMode: MyLocationTrackingMode.Tracking,
              ),
              if (_mapController.styleLoaded)
                InfoWindow( // Custom info window widget
                  selectedTerminal: _mapController.selectedTerminal,
                  onClose: () {
                    setState(() {
                      _mapController.clearSelectedTerminal();
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

// models/terminal.dart
import 'package:mapbox_gl/mapbox_gl.dart';

class Terminal {
  final String name;
  final List<LatLng> points;
  final String routeColor;
  final String iconImage; 

  Terminal({
    required this.name,
    required this.points,
    required this.routeColor,
    required this.iconImage, 
  });
}

final List<Terminal> terminals = [
  Terminal(
    name: 'Muzon - Tungkong Mangga Terminal',
    points: [
      LatLng(14.796411, 121.0287),
      LatLng(14.791351, 121.07125),
      LatLng(14.787361, 121.070373),
      LatLng(14.786498, 121.069463),
      LatLng(14.785011, 121.069507),
      LatLng(14.785032, 121.074446),
      LatLng(14.786524, 121.074784),
      LatLng(14.789037, 121.074708),
      LatLng(14.788986, 121.075435),
      LatLng(14.789702, 121.075188),
    ],
    routeColor: "#f898f0",
    iconImage: 'jeepejeep.png', 
  ),
  Terminal(
    name: 'Muzon - Novaliches Terminal',
    points: [
      LatLng(14.796187,121.027788),
      LatLng(14.791351, 121.07125),
      LatLng(14.787361, 121.070373),    
      LatLng(14.786962,121.074808),
      LatLng(14.775385,121.076920)
      
    ],
    routeColor: "#e69b00",
    iconImage: 'ejeep.png', // Set the icon image
  ),
  Terminal (
    name: 'Muzon - Cubao Terminal',
    points: [
      LatLng(14.796721,121.028903),
      LatLng(14.809434,121.047067),
      LatLng(14.810470,121.047635),
      LatLng(14.822939,121.044950),
      LatLng(14.813167,121.072016),
      LatLng(14.802775,121.068815),
      LatLng(14.789062,121.074741),
      LatLng(14.786962,121.074808),
      LatLng(14.775385,121.076920)

    ],
    routeColor: "#ebc8ff",
    iconImage: 'ejeep.png',

  ),
  Terminal (
    name: 'San Jose del Monte - Tungko Terminal',
    points: [
      LatLng(14.815117,121.042915),
      LatLng(14.809434,121.047067),
      LatLng(14.802229,121.034812),
      LatLng(14.791384,121.071266),
      LatLng(14.787401,121.071293),
      LatLng(14.786944,121.069414),
      LatLng(14.786955,121.074798),
      LatLng(14.789055,121.074696),
      LatLng(14.789657,121.075501)

    ],
    routeColor: "#c18b3d",
    iconImage: 'jeep.png',

  ),
  
];
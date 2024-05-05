library terminals;
export 'lib/terminal_list.dart';

class Terminal {
  final double latitude;
  final double longitude;

  Terminal(this.latitude, this.longitude);

}

List<Terminal> terminals = [
  Terminal(14.796147,121.028105),
  Terminal(14.789779,121.075221)
];


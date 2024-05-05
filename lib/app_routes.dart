import 'package:flutter/material.dart';
import 'package:saanjologin/register_page.dart';
import 'package:saanjologin/main_map_page.dart';

const String registerRoute = '/register';
const String mapPageRoute = '/map_page';

Map<String, WidgetBuilder> getAppRoutes() {
  return {
    registerRoute: (context) => RegisterPage(),
    mapPageRoute:(context) => MapPage(),
  };
}
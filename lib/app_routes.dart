import 'package:flutter/material.dart';
import 'package:saanjologin/pages/login_page.dart';
import 'package:saanjologin/pages/register_page.dart';
import 'package:saanjologin/pages/map_page.dart';

// Route names
const String loginRoute = '/';
const String registerRoute = '/register';
const String mapPageRoute = '/map_page';

// Function to get all routes
Map<String, WidgetBuilder> getAppRoutes() {
  return {
    loginRoute: (context) => const LoginPage(),
    registerRoute: (context) => const RegisterPage(),
    mapPageRoute: (context) => MapPage(),
  };
}

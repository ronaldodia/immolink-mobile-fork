import 'package:flutter/material.dart';
import 'package:immolink_mobile/utils/route_name.dart';
import 'package:immolink_mobile/views/screens/account_screen.dart';
import 'package:immolink_mobile/views/screens/home_screen.dart';
import 'package:immolink_mobile/views/screens/language_screen.dart';
import 'package:immolink_mobile/views/screens/login_screen.dart';
import 'package:immolink_mobile/views/screens/map_screen.dart';

class CustomeRoute {
  static Route<dynamic> allRoutes(RouteSettings settings) {
    switch (settings.name) {
      // case onBoardingRoute:
      //   return MaterialPageRoute(builder: (_) => const OnBoardingScreen());
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case languageRoute:
        return MaterialPageRoute(builder: (_) => const LanguageScreen());
      case accountRoute:
        return MaterialPageRoute(builder: (_) => const AccountScreen());
      case loginRoute:
        return MaterialPageRoute(builder: (_) =>  LoginScreen());
      case mapRoute:
        return MaterialPageRoute(builder: (_) => const MapScreen());
      // case aboutRoute:
      //   return MaterialPageRoute(builder: (_) => const AboutScreen());
      // case settingsRoute:
      //   return MaterialPageRoute(builder: (_) => const SettingScreen());
    }

    return MaterialPageRoute(builder: (_) => const HomeScreen());
  }
}
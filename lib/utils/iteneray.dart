import 'package:flutter/material.dart';
import 'package:immolink_mobile/utils/route_name.dart';
import 'package:immolink_mobile/views/screens/account_screen.dart';
import 'package:immolink_mobile/views/screens/bottom_navigation_menu.dart';
import 'package:immolink_mobile/views/screens/filters/filter_screen.dart';
import 'package:immolink_mobile/views/screens/forgot_password_screen.dart';
import 'package:immolink_mobile/views/screens/language_screen.dart';
import 'package:immolink_mobile/views/screens/login_phone_screen.dart'; 
import 'package:immolink_mobile/views/screens/map_screen.dart';
import 'package:immolink_mobile/views/screens/onboarding/onboarding_screen.dart';
import 'package:immolink_mobile/views/screens/register_phone_screen.dart';
import 'package:immolink_mobile/views/screens/verify_email_screen.dart';

class CustomeRoute {
  static Route<dynamic> allRoutes(RouteSettings settings) {
    switch (settings.name) {
      // case onBoardingRoute:
      //   return MaterialPageRoute(builder: (_) => const OnBoardingScreen());
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const BottomNavigationMenu());
      case languageRoute:
        return MaterialPageRoute(builder: (_) => const LanguageScreen());
      case accountRoute:
        return MaterialPageRoute(builder: (_) => const AccountScreen());
        case filterRoute:
        return MaterialPageRoute(builder: (_) =>  const FilterScreen());
      case loginRoute:
        return MaterialPageRoute(builder: (_) =>  const LoginPhoneScreen());
      // case loginRoute:
      //   return MaterialPageRoute(builder: (_) =>  const LoginScreen());
      // case loginRoute:
      //   return MaterialPageRoute(builder: (_) =>  const LoginScreen());
      case registerRoute:
        return MaterialPageRoute(builder: (_) =>  const RegisterPhoneScreen());
      case verifyEmail:
        return MaterialPageRoute(builder: (_) =>  const VerifyEmailScreen());
      case mapRoute:
        return MaterialPageRoute(builder: (_) =>  const MapScreen());
      case onBoardingRoute:
        return MaterialPageRoute(builder: (_) => const OnBoardingScreen());
      case forgotPasswordRoute:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      // case aboutRoute:
      //   return MaterialPageRoute(builder: (_) => const AboutScreen());
      // case settingsRoute:
      //   return MaterialPageRoute(builder: (_) => const SettingScreen());
    }

    return MaterialPageRoute(builder: (_) => const BottomNavigationMenu());
  }
}
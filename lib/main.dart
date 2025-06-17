import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:immolink_mobile/bindings/general_bindings.dart';
import 'package:immolink_mobile/controllers/currency/currency_controller.dart';
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'package:immolink_mobile/firebase_options.dart';
import 'package:immolink_mobile/l10n/app_localizations.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/services/notification/notification_services.dart';
import 'package:immolink_mobile/utils/iteneray.dart';
import 'package:immolink_mobile/views/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialiser le contrôleur de langue
  Get.put(LanguageController());

  // Demander les permissions de notification
  requestPermission();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController = Get.find();

    return Obx(() => GetMaterialApp(
          title: 'IMMOLINK',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
            useMaterial3: true,
          ),
          locale: languageController.locale,
          themeMode: ThemeMode.system,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fr'), // Français
            Locale('en'), // English
            Locale('ar'), // Arabic
          ],
          onGenerateRoute: CustomeRoute.allRoutes,
          home: const SplashScreen(),
        ));
  }
}

void requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else {
    print('User declined or has not accepted permission');
  }
}

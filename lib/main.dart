import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'package:immolink_mobile/firebase_options.dart';
import 'package:immolink_mobile/l10n/app_localizations.dart';
import 'package:immolink_mobile/services/notification/notification_services.dart';
import 'package:immolink_mobile/utils/iteneray.dart';
import 'package:immolink_mobile/views/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Lire la langue sauvegardée AVANT le runApp
  final box = GetStorage();
  String? savedLanguage = box.read('language');
  Locale initialLocale = Locale(savedLanguage ?? 'fr');

  // Initialiser le contrôleur avec la locale lue
  Get.put(LanguageController(initialLocale));



  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationServices.instance.initialize();

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

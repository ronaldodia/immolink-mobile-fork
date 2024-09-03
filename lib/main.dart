import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:immolink_mobile/bindings/general_bindings.dart';
import 'package:immolink_mobile/bloc/authentication/auth_bloc.dart';
import 'package:immolink_mobile/bloc/authentication/auth_event.dart';
import 'package:immolink_mobile/bloc/authentication/login_bloc/profile_bloc_phone.dart';
import 'package:immolink_mobile/bloc/authentication/register/register_with_email_bloc.dart';
import 'package:immolink_mobile/bloc/authentication/register/register_with_phone_bloc.dart';
import 'package:immolink_mobile/bloc/currencies/currency_bloc.dart';
import 'package:immolink_mobile/bloc/languages/localization_bloc.dart';
import 'package:immolink_mobile/controllers/currency/currency_controller.dart';
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'package:immolink_mobile/firebase_options.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/utils/iteneray.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'bloc/authentication/login_bloc/profile_bloc.dart';

void main() async {
 final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();


  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
 // Initialize the LanguageController
 Get.put(LanguageController());
 Get.put(CurrencyController());
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform)
 .then((FirebaseApp value) => Get.put(AuthRepository()));

  // final prefs = await SharedPreferences.getInstance();
  // print('get auth_token ${prefs.getString('auth_token')}');
  runApp(

    const MyApp(),
  );

  // AuthRepository authRepository = AuthRepository();
  // authRepository.loginWithPhone('22241905565', 'password');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController = Get.find();
        return Obx(() => GetMaterialApp(
              title: 'Immo Place',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
                useMaterial3: true,
              ),
              locale: languageController.locale,  // This will automatically update when the locale changes
              // fallbackLocale: const Locale('en'),
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
              initialBinding: GeneralBindings(),
              home: const Scaffold(
                backgroundColor: Colors.blue,
                body: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
              // initialRoute: onBoardingRoute,
              // home: BlocBuilder<AuthBloc, AuthState>(
              //   builder: (context, authState) {
              //     if (authState is AuthInitial) {
              //       return const Center(child: CircularProgressIndicator());
              //     }
              //     if (authState is Authenticated) {
              //       return const AccountScreen();
              //     }
              //     if (authState is Unauthenticated) {
              //       return const LoginScreen();
              //     }
              //     return const Center(child: CircularProgressIndicator());
              //   },
              // ),
            )
        );
  }
}

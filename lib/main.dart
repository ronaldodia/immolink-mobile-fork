import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:immolink_mobile/bloc/currencies/currency_bloc.dart';
import 'package:immolink_mobile/bloc/languages/localization_bloc.dart';
import 'package:immolink_mobile/utils/iteneray.dart';
import 'package:immolink_mobile/utils/route_name.dart';
import 'package:immolink_mobile/views/screens/home_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LocalizationBloc>(
          create: (context) => LocalizationBloc(),
        ),
        BlocProvider<CurrencyBloc>(
          create: (context) => CurrencyBloc(),
        ),
      ],
      child: const MyApp(),
    ),
  );
  // runApp(BlocProvider(
  //   create: (context) => LocalizationBloc()..add(LoadSavedLocalization()),
  //   child: MyApp(),
  // ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizationBloc, LocalizationState>(
        builder: (context, state) {
      return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
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
        locale: state.locale,
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          for (var locale in supportedLocales) {
            if (locale.languageCode == deviceLocale?.languageCode &&
                locale.countryCode == deviceLocale?.countryCode) {
              return deviceLocale;
            }
          }

          return supportedLocales.first;
        },
        onGenerateRoute: CustomeRoute.allRoutes,
        // home: const MyHomePage(title: 'Flutter Demo Home Page'),
        // home: const HomeScreen(),
        initialRoute: homeRoute,
      );
    });
  }
}

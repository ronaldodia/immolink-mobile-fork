import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:immolink_mobile/bloc/authentication/auth_bloc.dart';
import 'package:immolink_mobile/bloc/authentication/auth_event.dart';
import 'package:immolink_mobile/bloc/authentication/auth_state.dart';
import 'package:immolink_mobile/bloc/currencies/currency_bloc.dart';
import 'package:immolink_mobile/bloc/languages/localization_bloc.dart';
import 'package:immolink_mobile/utils/iteneray.dart';
import 'package:immolink_mobile/utils/route_name.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:immolink_mobile/views/screens/account_screen.dart';
import 'package:immolink_mobile/views/screens/login_screen.dart';

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
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(AppStarted()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          onGenerateRoute: CustomeRoute.allRoutes,
          initialRoute: loginRoute,
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (authState is Authenticated) {
                return const AccountScreen();
              }
              if (authState is Unauthenticated) {
                return const LoginScreen();
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        );
      },
    );
  }
}

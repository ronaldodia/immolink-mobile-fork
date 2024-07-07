import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:immolink_mobile/bloc/authentication/auth_bloc.dart';
import 'package:immolink_mobile/bloc/authentication/auth_event.dart';
import 'package:immolink_mobile/bloc/authentication/login_bloc/profile_bloc_phone.dart';
import 'package:immolink_mobile/bloc/authentication/register/register_with_email_bloc.dart';
import 'package:immolink_mobile/bloc/authentication/register/register_with_phone_bloc.dart';
import 'package:immolink_mobile/bloc/currencies/currency_bloc.dart';
import 'package:immolink_mobile/bloc/languages/localization_bloc.dart';
import 'package:immolink_mobile/firebase_options.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/utils/iteneray.dart';
import 'package:immolink_mobile/utils/route_name.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/authentication/login_bloc/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
   );

  final prefs = await SharedPreferences.getInstance();
  print('get auth_token ${prefs.getString('auth_token')}');
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
        BlocProvider(
          create: (context) => ProfileBloc(AuthRepository()),
        ),
        BlocProvider(
          create: (context) => ProfileBlocPhone(AuthRepository()),
        ),
        BlocProvider(
          create: (context) => RegisterWithEmailBloc(AuthRepository()),
        ),
        BlocProvider(
          create: (context) => RegisterWithPhoneBloc(AuthRepository()),
        ),

      ],
      child: const MyApp(),
    ),
  );

  // AuthRepository authRepository = AuthRepository();
  // authRepository.loginWithPhone('22241905565', 'password');
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
        );
      },
    );
  }
}

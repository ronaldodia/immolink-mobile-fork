import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:immolink_mobile/models/Currency.dart';

class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen({super.key});

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  final List<Currency> currencies = [
    Currency(
      code: 'MRU',
      name: 'Mauritania Ouguiya',
      imageUrl: 'assets/flags/mauritania.png',
      exchangeRate: 1.0,
      symbol: 'UM',
    ),
    Currency(
      code: 'EUR',
      name: 'Euro',
      imageUrl: 'assets/flags/europe.png',
      exchangeRate: 0.82,
      symbol: '€',
    ),
    Currency(
      code: 'USD',
      name: 'US Dollar',
      imageUrl: 'assets/flags/usd.png',
      exchangeRate: 1.0,
      symbol: '\$',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(
        elevation: 16.0,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.hello_world,
                style: Theme.of(context).textTheme.headlineMedium),
            Text(AppLocalizations.of(context)!.language,
                style: Theme.of(context).textTheme.titleMedium),
            Text(AppLocalizations.of(context)!.example_text,
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
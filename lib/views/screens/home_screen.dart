import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:immolink_mobile/bloc/currencies/currency_bloc.dart';
import 'package:immolink_mobile/bloc/currencies/currency_event.dart';
import 'package:immolink_mobile/bloc/currencies/currency_state.dart';
import 'package:immolink_mobile/models/Currency.dart';
import 'package:immolink_mobile/views/screens/language_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    Currency? selectedCurrency = currencies[2];
    return Scaffold(
      drawer: const Drawer(
        elevation: 16.0,
      ),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.name),
        actions: [
          BlocBuilder<CurrencyBloc, CurrencyState>(
            builder: (context, state) {
              if (state is CurrencyInitial || state is CurrencyChangedState) {
                final selectedCurrency = state is CurrencyInitial
                    ? state.selectedCurrency
                    : (state as CurrencyChangedState).selectedCurrency;
                final currencies = state is CurrencyInitial
                    ? state.currencies
                    : (state as CurrencyChangedState).currencies;

                return DropdownButton<Currency>(
                  value: selectedCurrency,
                  items: currencies.map((Currency currency) {
                    return DropdownMenuItem<Currency>(
                      value: currency,
                      child: Row(
                        children: [
                          Image.asset(
                            currency.imageUrl,
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currency.code,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (Currency? newValue) {
                    if (newValue != null) {
                      context
                          .read<CurrencyBloc>()
                          .add(ChangeCurrency(newValue));
                    }
                  },
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const LanguageScreen();
                }));
              },
              icon: const Icon(Icons.language)),
        ],
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

import 'package:bloc/bloc.dart';
import 'package:immolink_mobile/bloc/currencies/currency_event.dart';
import 'package:immolink_mobile/bloc/currencies/currency_state.dart';
import 'package:immolink_mobile/models/Currency.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  CurrencyBloc() : super(CurrencyInitial(_currencies[0], _currencies)) {
    on<ChangeCurrency>(_onChangeCurrency);
    _loadCurrency();
  }

  static const String _selectedCurrencyKey = 'selected_currency';

  static final List<Currency> _currencies = [
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

  void _onChangeCurrency(ChangeCurrency event, Emitter<CurrencyState> emit) async {
    emit(CurrencyChangedState(selectedCurrency: event.currency, currencies: _currencies));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedCurrencyKey, event.currency.code);
  }

  void _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_selectedCurrencyKey);
    if (code != null) {
      final currency = _currencies.firstWhere((c) => c.code == code, orElse: () => _currencies[0]);
      add(ChangeCurrency(currency));
    }
  }
}

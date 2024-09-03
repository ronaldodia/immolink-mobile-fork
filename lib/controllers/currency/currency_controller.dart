import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:immolink_mobile/models/Currency.dart';

class CurrencyController extends GetxController {
  final GetStorage _box = GetStorage();
  var selectedCurrency = Currency(
    code: 'USD',
    name: 'US Dollar',
    imageUrl: 'assets/flags/usd.png',
    exchangeRate: 1.0,
    symbol: '\$',
  ).obs;
  var currencies = <Currency>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Charger les devises disponibles
    currencies.addAll([
      Currency(
        code: 'MRU',
        name: 'Mauritania Ouguiya',
        imageUrl: 'assets/flags/mauritania.png',
        exchangeRate: 1.0, // MRU est la monnaie de base
        symbol: 'UM',
      ),
      Currency(
        code: 'EUR',
        name: 'Euro',
        imageUrl: 'assets/flags/europe.png',
        exchangeRate: 0.024, // 1 MRU ≈ 0.024 EUR (approximation)
        symbol: '€',
      ),
      Currency(
        code: 'USD',
        name: 'US Dollar',
        imageUrl: 'assets/flags/usd.png',
        exchangeRate: 0.027, // 1 MRU ≈ 0.027 USD (approximation)
        symbol: '\$',
      )
      // Ajoutez d'autres devises ici...
    ]);

    // Charger la devise sauvegardée au démarrage
    String? savedCurrencyCode = _box.read('currency');
    if (savedCurrencyCode != null) {
      selectedCurrency.value =
          currencies.firstWhere((currency) => currency.code == savedCurrencyCode);
    }
  }

  void changeCurrency(Currency newCurrency) {
    selectedCurrency.value = newCurrency;
    _box.write('currency', newCurrency.code);
  }
}

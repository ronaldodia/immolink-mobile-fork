import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:immolink_mobile/models/Currency.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:collection/collection.dart';

class CurrencyController extends GetxController {
  final GetStorage _box = GetStorage();
  var selectedCurrency = Rxn<Currency>();
  var currencies = <Currency>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;
  var currentExchangeRate = 1.0.obs;
  var currentSymbol = 'MRU'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCurrencies();
    loadSavedCurrency();

    // Écouter les changements de devise sélectionnée
    ever(selectedCurrency, (Currency? currency) {
      if (currency != null) {
        currentExchangeRate.value = currency.exchangeRate;
        currentSymbol.value = currency.symbol;
      }
    });
  }

  Future<void> fetchCurrencies() async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await http.get(
        Uri.parse('${Config.baseUrlApp}/home/currencies'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> currenciesJson = data['data'];
          currencies.value =
              currenciesJson.map((json) => Currency.fromJson(json)).toList();

          // Si une devise sauvegardée existe, la sélectionner via changeCurrency
          final savedCurrencyJson = _box.read('selected_currency');
          if (savedCurrencyJson != null) {
            final savedCurrency = Currency.fromJson(savedCurrencyJson);
            final found =
                currencies.firstWhereOrNull((c) => c.id == savedCurrency.id);
            if (found != null) {
              changeCurrency(
                  found); // <-- Utilise le setter pour tout mettre à jour
            } else {
              changeCurrency(currencies.first);
            }
          } else if (selectedCurrency.value == null && currencies.isNotEmpty) {
            changeCurrency(currencies.first);
          }
        } else {
          error.value = 'Erreur lors du chargement des devises';
        }
      } else {
        error.value = 'Erreur de connexion au serveur';
      }
    } catch (e) {
      error.value = 'Une erreur est survenue';
    } finally {
      isLoading.value = false;
    }
  }

  void loadSavedCurrency() {
    final savedCurrencyJson = _box.read('selected_currency');
    if (savedCurrencyJson != null) {
      try {
        selectedCurrency.value = Currency.fromJson(savedCurrencyJson);
      } catch (e) {
        print('Erreur lors du chargement de la devise sauvegardée: $e');
      }
    }
  }

  void changeCurrency(Currency newCurrency) {
    selectedCurrency.value = newCurrency;
    _box.write('selected_currency', newCurrency.toJson());
    currentExchangeRate.value = newCurrency.exchangeRate;
    currentSymbol.value = newCurrency.symbol;
  }

  String formatPrice(double price) {
    if (selectedCurrency.value == null) {
      return '${price.toStringAsFixed(0)} MRU';
    }
    return '${(price * currentExchangeRate.value).toStringAsFixed(0)} ${currentSymbol.value}';
  }

  double convertPrice(double price) {
    if (selectedCurrency.value == null) {
      return price;
    }
    return price * currentExchangeRate.value;
  }

  String getCurrentSymbol() {
    return currentSymbol.value;
  }

  double getCurrentExchangeRate() {
    return currentExchangeRate.value;
  }

  // Méthode pour convertir un prix de MRU vers la devise sélectionnée
  double convertFromMRU(double mruPrice) {
    if (selectedCurrency.value == null) {
      return mruPrice;
    }
    return mruPrice * selectedCurrency.value!.exchangeRate;
  }

  // Méthode pour convertir un prix de la devise sélectionnée vers MRU
  double convertToMRU(double price) {
    if (selectedCurrency.value == null) {
      return price;
    }
    return price / selectedCurrency.value!.exchangeRate;
  }

  // Méthode pour formater un prix avec le symbole de la devise
  String formatPriceWithSymbol(double price) {
    if (selectedCurrency.value == null) {
      return '${price.toStringAsFixed(0)} MRU';
    }
    return '${price.toStringAsFixed(0)} ${selectedCurrency.value!.symbol}';
  }
}

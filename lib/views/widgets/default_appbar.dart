import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:immolink_mobile/controllers/currency/currency_controller.dart';
import 'package:immolink_mobile/controllers/login/check_auth_controller.dart';
import 'package:immolink_mobile/models/Currency.dart';
import 'package:immolink_mobile/views/screens/login_phone_screen.dart';
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'package:immolink_mobile/models/LanguageModel.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DefaultAppBar({
    super.key,
  });

  // Méthode pour vérifier l'état de connexion
  Future<bool> checkLoginStatus() async {
    final localStorage = GetStorage();
    final CheckAuthController authController = Get.put(CheckAuthController());

    final String? token = await localStorage.read('AUTH_TOKEN');

    // Vérifiez si le token est nul avant de continuerp
    if (token == null) {
      // Redirigez vers la page de connexion
      Get.to(() => const LoginPhoneScreen());
      return false;
    }

    // Le token n'est pas nul, continuez à vérifier sa validité
    final response = await authController.checkToken(token);
    print('Reponse $response');

    if (response) {
      return true;
    } else {
      // Token invalide, supprimez le token et redirigez
      localStorage.remove('AUTH_TOKEN');
      Get.to(() => const LoginPhoneScreen());
      return false;
    }
  }

  void showLanguagePicker(BuildContext context) {
    final LanguageController languageController =
        Get.find<LanguageController>();
    final groupValue = languageController.locale.languageCode;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text('Choisir la langue',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ...languageModel.map((item) => RadioListTile(
                  value: item.languageCode,
                  groupValue: groupValue,
                  title: Text(item.language),
                  subtitle: Text(item.subLanguage),
                  onChanged: (value) async {
                    languageController.changeLanguage(item.languageCode);
                    Navigator.of(context).pop();
                  },
                )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void showCurrencyPicker(BuildContext context) {
    final CurrencyController currencyController =
        Get.find<CurrencyController>();
    final selectedCurrency = currencyController.selectedCurrency.value;

    print('showCurrencyPicker called');
    print('Currencies count: ${currencyController.currencies.length}');
    print('Selected currency: ${selectedCurrency?.code}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choisir la devise',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              if (currencyController.currencies.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Aucune devise disponible',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...currencyController.currencies.map((Currency currency) {
                  final isSelected = selectedCurrency?.id == currency.id;
                  final isMRU = currency.code == 'MRU';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[50] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? Colors.blue[300]! : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: RadioListTile<Currency>(
                      value: currency,
                      groupValue: selectedCurrency,
                      title: Row(
                        children: [
                          Image.network(
                            currency.imageUrl,
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.currency_exchange),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${currency.name} (${currency.code})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                if (!isMRU) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber[100],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.amber[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '1 ${currency.code} = ${currency.exchangeRate.toStringAsFixed(2)} MRU',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.amber[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      onChanged: (Currency? newValue) {
                        if (newValue != null) {
                          print('Currency selected: ${newValue.code}');
                          currencyController.changeCurrency(newValue);
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  );
                }).toList(),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final CurrencyController currencyController = Get.find();

    return AppBar(
      backgroundColor: Colors.white,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.person, size: 40),
            onPressed: () async {
              // Vérifier l'état de connexion avant d'ouvrir le drawer
              final isLoggedIn = await checkLoginStatus();
              if (isLoggedIn) {
                // Utiliser le contexte pour ouvrir le drawer
                Scaffold.of(context).openDrawer();
              }
            },
          );
        },
      ),
      actions: [
        Obx(() {
          if (currencyController.isLoading.value) {
            return const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          if (currencyController.error.isNotEmpty) {
            return IconButton(
              icon: const Icon(Icons.error_outline, color: Colors.red),
              onPressed: () => currencyController.fetchCurrencies(),
              tooltip: currencyController.error.value,
            );
          }

          if (currencyController.currencies.isEmpty) {
            return const SizedBox.shrink();
          }

          // S'assurer que la devise sélectionnée est dans la liste
          if (currencyController.selectedCurrency.value != null &&
              !currencyController.currencies
                  .contains(currencyController.selectedCurrency.value)) {
            currencyController.selectedCurrency.value =
                currencyController.currencies.first;
          }

          return Obx(() {
            final selectedCurrency = currencyController.selectedCurrency.value;
            if (selectedCurrency == null) {
              print('Selected currency is null');
              return const SizedBox.shrink();
            }

            print('Rendering currency button: ${selectedCurrency.code}');

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () {
                  print('Currency button tapped');
                  showCurrencyPicker(context);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(
                        selectedCurrency.imageUrl,
                        width: 20,
                        height: 20,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.currency_exchange, size: 20),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        selectedCurrency.code,
                        style: const TextStyle(
                          color: Color(0xFF1E40AF),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        }),
        IconButton(
          onPressed: () => showLanguagePicker(context),
          icon: const Icon(Icons.language),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

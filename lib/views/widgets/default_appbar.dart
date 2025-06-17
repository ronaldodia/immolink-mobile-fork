import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:immolink_mobile/controllers/currency/currency_controller.dart';
import 'package:immolink_mobile/controllers/login/check_auth_controller.dart';
import 'package:immolink_mobile/models/Currency.dart';
import 'package:immolink_mobile/views/screens/language_screen.dart';
import 'package:immolink_mobile/views/screens/login_phone_screen.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DefaultAppBar({
    super.key,
  });

  // Méthode pour vérifier l'état de connexion
  Future<bool> checkLoginStatus() async {
    final localStorage = GetStorage();
    final CheckAuthController authController = Get.put(CheckAuthController());

    final String? token = await localStorage.read('AUTH_TOKEN');

    // Vérifiez si le token est nul avant de continuer
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

          return Obx(() => DropdownButton<Currency>(
                value: currencyController.selectedCurrency.value,
                items: currencyController.currencies.map((Currency currency) {
                  return DropdownMenuItem<Currency>(
                    value: currency,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(
                          currency.imageUrl,
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.currency_exchange),
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
                    currencyController.changeCurrency(newValue);
                  }
                },
              ));
        }),
        IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const LanguageScreen();
            }));
          },
          icon: const Icon(Icons.language),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/currency/currency_controller.dart';
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'package:immolink_mobile/models/Currency.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:immolink_mobile/views/screens/language_screen.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DefaultAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final CurrencyController currencyController = Get.find();
    final LanguageController languageController = Get.find();

    return AppBar(
      backgroundColor: Colors.white,
      // title: const Icon(Icons.person, size: 40,),
      leading: IconButton(
        icon: const Icon(Icons.person, size: 40),
        onPressed: () {
          Scaffold.of(context).openDrawer(); // Ouvre le Drawer
        },
      ),
      actions: [
        Obx(() {
          // Vérifier si la monnaie sélectionnée est dans la liste
          if (!currencyController.currencies.contains(currencyController.selectedCurrency.value)) {
            currencyController.selectedCurrency.value = currencyController.currencies.first;
          }

          return DropdownButton<Currency>(
            value: currencyController.selectedCurrency.value,
            items: currencyController.currencies.map((Currency currency) {
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
                currencyController.changeCurrency(newValue);
              }
            },
          );
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

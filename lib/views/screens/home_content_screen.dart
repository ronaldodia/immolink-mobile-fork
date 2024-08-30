import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:immolink_mobile/models/Currency.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/utils/helpers.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:immolink_mobile/views/common/d_search_bar_widget.dart';
import 'package:immolink_mobile/views/common/d_section_heading.dart';
import 'package:immolink_mobile/views/common/d_vertical_image_text.dart';

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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: TSizes.spaceBtwSections,),
            // Searchbar -- tutorial [Section # 3]
             const SearchBarWidget(text: 'Search (Apartments, Home, Penthouse, Store)'),
            const SizedBox(height: TSizes.spaceBtwItems,),
            ///  Categories Header
             const Padding(
              padding: EdgeInsets.only(left: TSizes.defaultSpace),
              child: Column(
                children: [
                  DSectionHeading(title: 'Popular Categories', showActionButton: true,),
                ],
              ),
            ),
            /// Categories
            SizedBox(
              height: 80,
              child: ListView.builder(
                  itemCount: 6,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (_, index) {
                  return const DVerticalImageText(title: 'House',image: TImages.house, textColor: Colors.blueGrey, backgroundColor: Colors.white,);
                  }),
            ),

            const SizedBox(height: TSizes.spaceBtwSections,),
            Text(AppLocalizations.of(context)!.hello_world,
                style: Theme.of(context).textTheme.headlineMedium),
            Text(AppLocalizations.of(context)!.language,
                style: Theme.of(context).textTheme.titleMedium),
            Text(AppLocalizations.of(context)!.example_text,
                style: Theme.of(context).textTheme.titleMedium),
            IconButton(onPressed: () {
              AuthRepository.instance.logout();
              final localStorage = GetStorage();
              AuthRepository.instance.logOutBackend(localStorage.read('AUTH_TOKEN'));
            }, icon: const Text('Logout'))
          ],
        ),
      ),
    );
  }
}






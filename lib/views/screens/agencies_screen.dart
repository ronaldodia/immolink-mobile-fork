import 'package:flutter/material.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:immolink_mobile/views/common/agency_card_widget.dart';
import 'package:immolink_mobile/views/common/d_search_bar_widget.dart';

class AgenciesScreen extends StatelessWidget {
  const AgenciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculer le childAspectRatio en fonction de la largeur de l'écran
    // double aspectRatio = screenWidth / (2.0 * 0.75);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Agencies'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SearchBarWidget(
                text: 'Search Agency',
                secondIcon: Icons.location_on_rounded,
              ),
              const SizedBox(
                height: 4,
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: 7,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Deux éléments par ligne
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  return const AgencyCardWidget(
                    image: TImages.featured1,
                    name: 'Agences',
                    properties: 5,
                    rating: 4.0,
                  );
                },
              ),
            ]),
      ),
    );
  }
}

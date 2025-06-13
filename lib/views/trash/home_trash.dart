///  Featured Header
              // Obx(() {
              //   if (articlePromotionController.isLoading.value) {
              //     // Affiche l'effet shimmer pour l'en-tête lorsque les données sont en cours de chargement
              //     return Padding(
              //       padding: const EdgeInsets.only(left: TSizes.defaultSpace),
              //       child: Shimmer.fromColors(
              //         baseColor: getGreyColor(300),
              //         highlightColor: getGreyColor(100),
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Container(
              //               width:
              //                   150, // Ajuste la largeur selon la taille souhaitée pour le titre
              //               height:
              //                   20, // Ajuste la hauteur selon la taille souhaitée pour le titre
              //               color: Colors.white,
              //             ),
              //             const SizedBox(height: 8),
              //             Container(
              //               width:
              //                   100, // Ajuste la largeur selon la taille souhaitée pour le bouton d'action
              //               height:
              //                   20, // Ajuste la hauteur selon la taille souhaitée pour le bouton d'action
              //               color: Colors.white,
              //             ),
              //           ],
              //         ),
              //       ),
              //     );
              //   } else {
              //     // Affiche l'en-tête normal lorsque les données sont chargées
              //     return const Padding(
              //       padding: EdgeInsets.only(left: TSizes.defaultSpace),
              //       child: Column(
              //         children: [
              //           DSectionHeading(
              //             title: 'Featured',
              //             showActionButton: true,
              //           ),
              //         ],
              //       ),
              //     );
              //   }
              // }),
              // // Featured Property
              // Obx(() {
              //   if (articlePromotionController.isLoading.value) {
              //     // Affiche l'effet shimmer pendant le chargement
              //     return SizedBox(
              //       height: 780,
              //       child: ListView.builder(
              //         // Utilisation de `ListView.builder` pour générer des éléments de chargement
              //         itemCount:
              //             5, // Nombre d'éléments de chargement à afficher (ajuste si nécessaire)
              //         itemBuilder: (context, index) {
              //           return Shimmer.fromColors(
              //             baseColor: getGreyColor(300),
              //             highlightColor: getGreyColor(100),
              //             child: Padding(
              //               padding: const EdgeInsets.symmetric(
              //                   vertical: 8.0, horizontal: 16.0),
              //               child: Container(
              //                 height:
              //                     180, // Ajuste la hauteur en fonction des besoins
              //                 decoration: BoxDecoration(
              //                   color: Colors.white,
              //                   borderRadius: BorderRadius.circular(8),
              //                 ),
              //               ),
              //             ),
              //           );
              //         },
              //       ),
              //     );
              //   }

              //   if (articlePromotionController.featuredProperties.isEmpty) {
              //     return const Center(child: Text('No properties found'));
              //   }

              //   return SizedBox(
              //     height: 780,
              //     child: ListView.builder(
              //       // shrinkWrap: true,
              //       physics: const NeverScrollableScrollPhysics(),
              //       itemCount:
              //           articlePromotionController.featuredProperties.length,
              //       itemBuilder: (context, index) {
              //         final property =
              //             articlePromotionController.featuredProperties[index];
              //         return PropertyCardWidget(
              //           image: property.image,
              //           isFeatured: true,
              //           favoriteIcon: Icons.favorite_border,
              //           categoryIcon: property.category!.image ?? '',
              //           status: property.purpose,
              //           category: property.category!.name,
              //           price: property.price,
              //           name: property.getPropertyByLanguage(
              //                   language.locale.languageCode,
              //                   propertyType: "name") ??
              //               'Test',
              //           location: 'Cite Plage',
              //           onTap: () async {
              //             // Affiche un dialogue de chargement
              //             showDialog(
              //               context: context,
              //               barrierDismissible: false,
              //               builder: (BuildContext context) {
              //                 return const Center(
              //                   child: CircularProgressIndicator(),
              //                 );
              //               },
              //             );
              //             // Attendre quelques secondes pour simuler un chargement
              //             await Future.delayed(const Duration(seconds: 2));
              //             // Fermer le dialogue de chargement
              //             Navigator.pop(context);
              //             // Naviguer vers la page des détails
              //             Get.to(() =>
              //                 FutureadArticleDetailsScreen(property: property));
              //           },
              //           onFavoriteTap: () {
              //             print(
              //                 'FAVORITE BUTTON: ${property.getPropertyByLanguage(language.locale.languageCode, propertyType: "name")}');
              //           },
              //         );
              //       },
              //     ),
              //   );
              // }),

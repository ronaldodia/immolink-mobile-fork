import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:immolink_mobile/controllers/home/article_promotion_controller.dart';
import 'package:immolink_mobile/controllers/home/categories_controller.dart';
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'package:immolink_mobile/models/Currency.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:immolink_mobile/views/common/d_horizontal_image_text.dart';
import 'package:immolink_mobile/views/common/d_search_bar_widget.dart';
import 'package:immolink_mobile/views/common/d_section_heading.dart';
import 'package:immolink_mobile/views/common/featured_property_card.dart';
import 'package:immolink_mobile/views/common/property_card_widget.dart';
import 'package:immolink_mobile/views/screens/article/futuread_article_details_screen.dart';
import 'package:immolink_mobile/views/screens/article/promote_article_details_screen.dart';
import 'package:immolink_mobile/views/widgets/default_appbar.dart';
import 'package:shimmer/shimmer.dart';

class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen({super.key});

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {

  final CategoryController categoryController = Get.put(CategoryController());
  final ArticlePromotionController articlePromotionController =
  Get.put(ArticlePromotionController());

  final ScrollController _scrollController = ScrollController();
  final LanguageController language = Get.find();

  // Simulez la méthode d'actualisation des données
  Future<void> _refreshData() async {
    // Simule un délai avant le rafraîchissement (vous pouvez mettre la logique réelle ici)
    await Future.delayed(const Duration(seconds: 2));
    // Vous pouvez appeler ici votre fonction pour recharger les données de l'API
    categoryController.fetchCategories(language.locale.languageCode);
    articlePromotionController.fetchPromotionProperties();
    articlePromotionController.fetchFeaturedProperties();
  }
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
      drawer: _buildDrawer(context),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: TSizes.spaceBtwItems,
              ),
              // Searchbar -- tutorial [Section # 3]
              Obx(() {
                if (categoryController.isLoading.value) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 16.0),
                      height: 50, // Hauteur de la SearchBarWidget
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  );
                } else {
                  return  const SearchBarWidget(
                    text: 'Rechercher...',
                    );
                }
              }),
              const SizedBox(
                height: TSizes.spaceBtwItems,
              ),
        
              ///  Categories Header
              Obx(() {
                if (categoryController.isLoading.value) {
                  return Padding(
                    padding: const EdgeInsets.only(left: TSizes.defaultSpace),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width:
                                150, // Ajuste selon la largeur souhaitée pour le titre
                            height:
                                20, // Ajuste selon la hauteur souhaitée pour le titre
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width:
                                100, // Ajuste selon la largeur souhaitée pour le bouton d'action
                            height:
                                10, // Ajuste selon la hauteur souhaitée pour le bouton d'action
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.only(left: TSizes.defaultSpace),
                    child: Column(
                      children: [
                        DSectionHeading(
                          title: 'Categories',
                          showActionButton: false,
                        ),
                      ],
                    ),
                  );
                }
              }),
        
              const SizedBox(
                height: 4,
              ),
        
              /// Categories
              SizedBox(
                height: 50,
                child: Obx(() {
                  if (categoryController.isLoading.value) {
                    return ListView.builder(
                      // scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          3, // Nombre d'éléments à afficher pendant le chargement
                      itemBuilder: (_, index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            width:
                                30, // Ajuste selon la largeur souhaitée pour chaque élément
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width:
                                      100, // Ajuste selon la largeur souhaitée pour l'image
                                  height:
                                      100, // Ajuste selon la hauteur souhaitée pour l'image
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width:
                                      100, // Ajuste selon la largeur souhaitée pour le texte
                                  height:
                                      100, // Ajuste selon la hauteur souhaitée pour le texte
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
        
                  return SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categoryController.categories.length,
                        itemBuilder: (_, index) {
                          var category = categoryController.categories[index];
                          return DHorizontalImageText(
                            title: category['name'] ?? 'Unknown',
                            image: category['image'] ??
                                'default_image.png', // Si l'image n'est pas présente
                            textColor: Colors.blueGrey,
                            backgroundColor: Colors.white,
                          );
                        },
                      ));
                }),
              ),
        
              const SizedBox(
                height: TSizes.spaceBtwItems,
              ),
              //Promotion property
              Obx(() {
                if (articlePromotionController.isLoading.value) {
                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5, // Nombre d'éléments à afficher pendant le chargement
                      itemBuilder: (_, index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            width: 150, // Ajuste selon la largeur souhaitée pour chaque carte
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity, // Ajuste selon la largeur souhaitée pour l'image
                                  height: 120, // Ajuste selon la hauteur souhaitée pour l'image
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 100, // Ajuste selon la largeur souhaitée pour le texte
                                  height: 12, // Ajuste selon la hauteur souhaitée pour le texte
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 80, // Ajuste selon la largeur souhaitée pour le texte
                                  height: 12, // Ajuste selon la hauteur souhaitée pour le texte
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: articlePromotionController.promotionProperties.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, index) {
                          var property = articlePromotionController.promotionProperties[index].article;
                          return FeaturedPropertyCard(
                            image: property!.image,
                            status: property.purpose, // Vous pouvez récupérer à partir des données
                            isFeatured: true,
                            onTap: () async {
                              // Affiche un dialogue de chargement
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              );
                              // Attendre quelques secondes pour simuler un chargement
                              await Future.delayed(const Duration(seconds: 2));
                              // Fermer le dialogue de chargement
                              Navigator.pop(context);
                              // Naviguer vers la page des détails
                              Get.to(() => PromoteArticleDetailsScreen(property: property));
                            },
                            categoryIcon: property.category!.image ?? '', // Assurez-vous que l'icône est correcte
                            categoryName: property.category!.name ?? 'Nom indisponible', // Vous pouvez récupérer à partir des données
                            name: property.name ?? 'Nom indisponible',
                            location: 'Cite Plage',
                            price: property.price,
                            amenities: const [Icons.add, Icons.school],
                          );
                        },
                      )
                  );
                }
              }),
        
        
              ///  Featured Header
              Obx(() {
                if (articlePromotionController.isLoading.value) {
                  // Affiche l'effet shimmer pour l'en-tête lorsque les données sont en cours de chargement
                  return Padding(
                    padding: const EdgeInsets.only(left: TSizes.defaultSpace),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 150, // Ajuste la largeur selon la taille souhaitée pour le titre
                            height: 20, // Ajuste la hauteur selon la taille souhaitée pour le titre
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 100, // Ajuste la largeur selon la taille souhaitée pour le bouton d'action
                            height: 20, // Ajuste la hauteur selon la taille souhaitée pour le bouton d'action
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  // Affiche l'en-tête normal lorsque les données sont chargées
                  return const Padding(
                    padding: EdgeInsets.only(left: TSizes.defaultSpace),
                    child: Column(
                      children: [
                        DSectionHeading(
                          title: 'Featured',
                          showActionButton: true,
                        ),
                      ],
                    ),
                  );
                }
              }),
            // Featured Property
              Obx(() {
                if (articlePromotionController.isLoading.value) {
                  // Affiche l'effet shimmer pendant le chargement
                  return SizedBox(
                    height: 780,
                    child: ListView.builder(
                      // Utilisation de `ListView.builder` pour générer des éléments de chargement
                      itemCount: 5, // Nombre d'éléments de chargement à afficher (ajuste si nécessaire)
                      itemBuilder: (context, index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: Container(
                              height: 180, // Ajuste la hauteur en fonction des besoins
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
        
                if (articlePromotionController.featuredProperties.isEmpty) {
                  return const Center(child: Text('No properties found'));
                }
        
                return SizedBox(
                  height: 780,
                  child: ListView.builder(
                    // shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: articlePromotionController.featuredProperties.length,
                    itemBuilder: (context, index) {
                      final property = articlePromotionController.featuredProperties[index];
                      return PropertyCardWidget(
                        image: property.image ?? TImages.featured1,
                        isFeatured: true,
                        favoriteIcon: Icons.favorite_border,
                        categoryIcon: property.category!.image ?? '',
                        status: property.purpose,
                        category: property.category!.name,
                        price: property.price,
                        name: property.name ?? 'Test',
                        location: 'Cite Plage',
                        onTap: () async {
                          // Affiche un dialogue de chargement
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );
                          // Attendre quelques secondes pour simuler un chargement
                          await Future.delayed(const Duration(seconds: 2));
                          // Fermer le dialogue de chargement
                          Navigator.pop(context);
                          // Naviguer vers la page des détails
                          Get.to(() => FutureadArticleDetailsScreen(property: property));
                        },
                        onFavoriteTap: () {
                          print('FAVORITE BUTTON: ${property.name}');
                        },
                      );
                    },
                  ),
                );
              }),
        
              //
        
              const SizedBox(
                height: TSizes.spaceBtwSections,
              ),
              Text(AppLocalizations.of(context)!.hello_world,
                  style: Theme.of(context).textTheme.headlineMedium),
              Text(AppLocalizations.of(context)!.language,
                  style: Theme.of(context).textTheme.titleMedium),
              Text(AppLocalizations.of(context)!.example_text,
                  style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                  onPressed: () {
                    AuthRepository.instance.logout();
                    final localStorage = GetStorage();
                    AuthRepository.instance
                        .logOutBackend(localStorage.read('AUTH_TOKEN'));
                  },
                  icon: const Text('Logout'))
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Scroll vers le haut de la page
          _scrollController.animateTo(
            0, // Position en haut de la page
            duration: const Duration(milliseconds: 500), // Durée de l'animation
            curve: Curves.easeInOut, // Effet d'animation
          );
        },
        backgroundColor: Colors.deepOrangeAccent.withOpacity(0.4), // Ajustez la couleur et l'opacité ici
        child: const Icon(Icons.arrow_upward),
      )
      ,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    String currentLanguage = language.locale.languageCode;
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec l'abréviation et le nom complet de l'utilisateur
          const UserAccountsDrawerHeader(
            accountName: Text('John Doe'),
            accountEmail: Text(''), // Abréviation
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                'JD',
                style: TextStyle(fontSize: 24.0),
              ),
            ),
          ),
          // Option Déconnexion en rouge
          ListTile(
            title: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.red),
            ),
            leading: const Icon(Icons.logout, color: Colors.red),
            onTap: () {
              // Logique de déconnexion ici
            },
          ),
          const Divider(),
          // Options de navigation
          ListTile(
            title: const Text('Notifications'),
            leading: const Icon(Icons.notifications),
            onTap: () {
              // Action pour Notifications
            },
          ),
          ListTile(
            title: const Text('Mes Réservations'),
            leading: const Icon(Icons.book_online),
            onTap: () {
              // Action pour Mes Réservations
            },
          ),
          ListTile(
            title: const Text('Mon Compte'),
            leading: const Icon(Icons.account_circle),
            onTap: () {
              // Action pour Mon Compte
            },
          ),
          ListTile(
            title: const Text('Mes Annonces'),
            leading: const Icon(Icons.announcement),
            onTap: () {
              // Action pour Mes Annonces
            },
          ),
          const Spacer(),
          // Liste horizontale pour la sélection de la langue
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLanguageOption('Ar', 'عربي', currentLanguage, context),
                _buildLanguageOption('Fr', 'Français', currentLanguage, context),
                _buildLanguageOption('En', 'English', currentLanguage, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour afficher une option de langue
  // Widget pour afficher une option de langue
  Widget _buildLanguageOption(
      String languageCode,
      String languageName,
      String currentLanguage,
      BuildContext context,
      ) {
    // Déterminer si cette langue est sélectionnée
    bool isSelected = languageCode.toLowerCase() == currentLanguage.toLowerCase();

    return GestureDetector(
      onTap: () {
        // Logique pour changer la langue
        language.changeLanguage(languageCode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.transparent, // Couleur active si sélectionnée
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          languageName,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.black, // Texte en bleu si sélectionné
          ),
        ),
      ),
    );
  }
}

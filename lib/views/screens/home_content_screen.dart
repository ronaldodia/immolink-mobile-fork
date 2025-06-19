import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:immolink_mobile/controllers/communes/commune_controller.dart';
import 'package:immolink_mobile/controllers/communes/district_controller.dart';
import 'package:immolink_mobile/controllers/home/article_promotion_controller.dart';
import 'package:immolink_mobile/controllers/home/categories_controller.dart';
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'package:immolink_mobile/l10n/app_localizations.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:immolink_mobile/views/common/d_horizontal_image_text.dart';
import 'package:immolink_mobile/views/common/d_search_bar_widget.dart';
import 'package:immolink_mobile/views/common/d_section_heading.dart';
import 'package:shimmer/shimmer.dart';
import 'package:immolink_mobile/utils/navigation_fix.dart';
import 'package:immolink_mobile/views/common/property_card_widget.dart';
import 'package:immolink_mobile/controllers/app_drawer_controller.dart';
import 'package:immolink_mobile/controllers/currency/currency_controller.dart';

// Fonction utilitaire pour gérer les couleurs de manière sécurisée
Color getGreyColor(int shade) {
  switch (shade) {
    case 100:
      return Colors.grey.shade100;
    case 200:
      return Colors.grey.shade200;
    case 300:
      return Colors.grey.shade300;
    default:
      return Colors.grey;
  }
}

class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen({super.key});

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  final CategoryController categoryController = Get.put(CategoryController());
  final DistrictController districtController = Get.put(DistrictController());
  final CommuneController communeController = Get.put(CommuneController());
  final ArticlePromotionController articlePromotionController =
      Get.put(ArticlePromotionController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _scrollController = ScrollController();
  final LanguageController language = Get.find();
  Map<String, dynamic>? userProfile =
      AuthRepository.instance.deviceStorage.read('USER_PROFILE');
  final CurrencyController currencyController = Get.put(CurrencyController());

  @override
  void initState() {
    super.initState();
    // Vérifier si le userProfile est null et le charger si nécessaire
    if (userProfile == null) {
      final token = AuthRepository.instance.deviceStorage.read('AUTH_TOKEN');
      if (token != null) {
        // Charger les données de l'utilisateur depuis le backend
        _loadUserProfile();
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final token = AuthRepository.instance.deviceStorage.read('AUTH_TOKEN');
      if (token != null) {
        final response = await http.get(
          Uri.parse('${Config.baseUrlApp}/profile'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          setState(() {
            userProfile = json.decode(response.body);
          });
        }
      }
    } catch (e) {
      print('Erreur lors du chargement du profil: $e');
    }
  }

  // Simulez la méthode d'actualisation des données
  Future<void> _refreshData() async {
    // Simule un délai avant le rafraîchissement (vous pouvez mettre la logique réelle ici)
    await Future.delayed(const Duration(seconds: 2));
    // Vous pouvez appeler ici votre fonction pour recharger les données de l'API
    categoryController.fetchCategories(language.locale.languageCode);
    articlePromotionController.fetchPromotionProperties();
    articlePromotionController.fetchFeaturedProperties();
  }

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    Get.put(_scaffoldKey);

    return Scaffold(
      key: _scaffoldKey,
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
                    baseColor: getGreyColor(300),
                    highlightColor: getGreyColor(100),
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
                  return const SearchBarWidget(
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
                      baseColor: getGreyColor(300),
                      highlightColor: getGreyColor(100),
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
                          baseColor: getGreyColor(300),
                          highlightColor: getGreyColor(100),
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
              // Section des promotions
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
                      itemCount:
                          5, // Nombre d'éléments à afficher pendant le chargement
                      itemBuilder: (_, index) {
                        return Shimmer.fromColors(
                          baseColor: getGreyColor(300),
                          highlightColor: getGreyColor(100),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            width:
                                150, // Ajuste selon la largeur souhaitée pour chaque carte
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double
                                      .infinity, // Ajuste selon la largeur souhaitée pour l'image
                                  height:
                                      120, // Ajuste selon la hauteur souhaitée pour l'image
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width:
                                      100, // Ajuste selon la largeur souhaitée pour le texte
                                  height:
                                      12, // Ajuste selon la hauteur souhaitée pour le texte
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width:
                                      80, // Ajuste selon la largeur souhaitée pour le texte
                                  height:
                                      12, // Ajuste selon la hauteur souhaitée pour le texte
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
                        itemCount: articlePromotionController
                            .promotionProperties.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, index) {
                          final promotion = articlePromotionController
                              .promotionProperties[index];
                          final property = promotion.article;

                          if (property == null) {
                            return const SizedBox
                                .shrink(); // Cache les éléments sans propriété
                          }

                          final propertyName = property.getPropertyByLanguage(
                            language.locale.languageCode,
                            propertyType: 'name',
                          );
                          final structureName = property.structure?.name;
                          final propertyLocation =
                              structureName != null && structureName.isNotEmpty
                                  ? structureName
                                  : 'Localisation non disponible';
                          final purpose =
                              property.purpose?.toLowerCase() ?? 'vente';

                          return PropertyCardWidget(
                            image: property.image,
                            isFeatured: true,
                            status: purpose,
                            category: property.category?.name ?? 'Autre',
                            price: property.price?.toDouble() ?? 0,
                            name: propertyName,
                            location: propertyLocation,
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

                              try {
                                // Attendre quelques secondes pour simuler un chargement
                                await Future.delayed(
                                    const Duration(seconds: 2));
                                // Fermer le dialogue de chargement et naviguer
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  // Utiliser la fonction de navigation unifiée
                                  navigateToPropertyDetails(property);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  Get.snackbar(
                                    'Erreur',
                                    'Impossible de charger les détails de la propriété',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              }
                            },
                            onFavoriteTap: () {
                              // TODO: Implémenter la logique d'ajout aux favoris
                            },
                          );
                        },
                      ));
                }
              }),
              // Featured articles
              Obx(() {
                if (articlePromotionController.isLoading.value) {
                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (_, __) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(left: TSizes.defaultSpace),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              width: 250,
                              padding: const EdgeInsets.all(TSizes.sm),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          TSizes.cardRadiusLg),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 100,
                                    height: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 80,
                                    height: 12,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else if (articlePromotionController
                    .promotionProperties.isEmpty) {
                  return const SizedBox.shrink();
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                            left: TSizes.defaultSpace,
                            top: TSizes.defaultSpace),
                        child: DSectionHeading(
                          title: 'Promotions',
                          showActionButton: false,
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: TSizes.defaultSpace),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: TSizes.spaceBtwItems,
                            mainAxisSpacing: TSizes.spaceBtwItems,
                          ),
                          itemCount: articlePromotionController
                              .promotionProperties.length,
                          itemBuilder: (context, index) {
                            final promotion = articlePromotionController
                                .promotionProperties[index];
                            final article = promotion.article;

                            if (article == null) {
                              return const SizedBox.shrink();
                            }

                            return GestureDetector(
                              onTap: () {
                                // Utiliser la fonction de navigation unifiée
                                navigateToPropertyDetails(article);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      TSizes.cardRadiusLg),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Image de l'article
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(
                                            TSizes.cardRadiusLg),
                                        topRight: Radius.circular(
                                            TSizes.cardRadiusLg),
                                      ),
                                      child: article.image.isNotEmpty
                                          ? Image.network(
                                              article.image,
                                              height: 120,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                height: 120,
                                                color: getGreyColor(200),
                                                child: const Icon(
                                                    Icons.image_not_supported),
                                              ),
                                            )
                                          : Container(
                                              height: 120,
                                              color: getGreyColor(200),
                                              child: const Icon(
                                                  Icons.image_not_supported),
                                            ),
                                    ),
                                    // Détails de l'article
                                    Padding(
                                      padding: const EdgeInsets.all(TSizes.sm),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            article.getPropertyByLanguage(
                                              language.locale.languageCode,
                                              propertyType: "name",
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.calendar_today,
                                                size: 12,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  '${promotion.startDate?.split('T')[0] ?? 'N/A'} - ${promotion.endDate?.split('T')[0] ?? 'N/A'}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  currencyController
                                                      .formatPrice(
                                                          article.price),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (article.reduction_percentage >
                                                  0) ...[
                                                const SizedBox(width: 4),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 4,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    '-${article.reduction_percentage}%',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              }),

              //
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
                    localStorage.remove('AUTH_TOKEN');
                  },
                  icon: const Text('Logout')),
              const SizedBox(
                width: TSizes.spaceBtwItems,
              ),
              Text(userProfile?['full_name'] ?? 'Nom inconnu')
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
        backgroundColor: Colors.deepOrangeAccent
            .withOpacity(0.4), // Ajustez la couleur et l'opacité ici
        child: const Icon(Icons.arrow_upward),
      ),
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
                _buildLanguageOption(
                    'Fr', 'Français', currentLanguage, context),
                _buildLanguageOption('En', 'English', currentLanguage, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour afficher une option de langue
  Widget _buildLanguageOption(
    String languageCode,
    String languageName,
    String currentLanguage,
    BuildContext context,
  ) {
    // Déterminer si cette langue est sélectionnée
    bool isSelected =
        languageCode.toLowerCase() == currentLanguage.toLowerCase();

    return GestureDetector(
      onTap: () {
        // Logique pour changer la langue
        language.changeLanguage(languageCode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? getGreyColor(200)
              : Colors.transparent, // Couleur active si sélectionnée
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          languageName,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Colors.black
                : Colors.black, // Texte en bleu si sélectionné
          ),
        ),
      ),
    );
  }
}

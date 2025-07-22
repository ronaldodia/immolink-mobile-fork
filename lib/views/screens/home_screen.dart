import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/home/categories_controller.dart';
import 'package:immolink_mobile/controllers/home/article_promotion_controller.dart';
import 'package:immolink_mobile/controllers/home/search_app_controller.dart';
import 'package:immolink_mobile/controllers/articles/filter_controller.dart';
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'package:immolink_mobile/controllers/currency/currency_controller.dart';
import 'package:immolink_mobile/controllers/login/check_auth_controller.dart';
import 'package:immolink_mobile/controllers/communes/commune_controller.dart';
import 'package:immolink_mobile/controllers/communes/district_controller.dart';
import 'package:immolink_mobile/views/screens/all_properties_screen.dart';
import 'package:immolink_mobile/views/screens/filters/filter_screen.dart';
import 'package:immolink_mobile/views/screens/login_phone_screen.dart';
import 'package:immolink_mobile/views/screens/agencies_screen.dart';
import 'package:immolink_mobile/views/screens/map_screen.dart';
import 'package:immolink_mobile/views/screens/article/articles_screen.dart';
import 'package:immolink_mobile/views/screens/chat_list_screen.dart';
import 'package:immolink_mobile/l10n/app_localizations.dart';
import 'package:immolink_mobile/utils/navigation_fix.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:get_storage/get_storage.dart';
import 'package:immolink_mobile/repository/auth_repository.dart';
import 'package:immolink_mobile/views/widgets/default_appbar.dart';

enum ContentState { loading, success, error }

class ContentLoader extends StatelessWidget {
  final Widget child;
  final ContentState state;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final double height;

  const ContentLoader({
    super.key,
    required this.child,
    required this.state,
    this.errorMessage,
    this.onRetry,
    this.height = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ContentState.loading:
        return _buildLoadingState();
      case ContentState.error:
        return _buildErrorState(context);
      case ContentState.success:
        return child;
    }
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: height,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.0,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16.0),
            Text(
              errorMessage ?? 'Une erreur est survenue',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 16.0),
            if (onRetry != null)
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 10.0),
                ),
                child: const Text(
                  'Réessayer',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ArticlePromotionController articlePromotionController =
      Get.put(ArticlePromotionController());
  final CategoryController categoryController = Get.put(CategoryController());
  final SearchAppController searchController = Get.put(SearchAppController());
  final FilterController filterController = Get.put(FilterController());
  final LanguageController languageController = Get.find();
  final CurrencyController currencyController = Get.find();
  final DistrictController districtController = Get.put(DistrictController());
  final CommuneController communeController = Get.put(CommuneController());
  final AuthRepository _authRepository = Get.put(AuthRepository());
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final RxBool _showSearchResults = false.obs;
  final RxBool _isSearchExpanded = false.obs;
  final RxBool _showFilterOverlay = false.obs;
  final Rx<int> selectIndex = 0.obs;

  // Propriétés pour gérer les états de chargement et d'erreur
  final RxBool _isLoadingCategories = false.obs;
  final RxBool _isLoadingFeatured = false.obs;
  final RxString _categoriesError = ''.obs;
  final RxString _featuredError = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadFeaturedProperties();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      drawer: _buildDrawer(),
      backgroundColor: Colors.white,
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          backgroundColor: Colors.white,
          selectedIndex: selectIndex.value,
          onDestinationSelected: onDestinationSelected,
          destinations: [
            NavigationDestination(
              icon: SvgPicture.asset(
                TImages.home,
                colorFilter:
                    const ColorFilter.mode(Colors.blueGrey, BlendMode.srcIn),
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                TImages.officeSvg,
                colorFilter:
                    const ColorFilter.mode(Colors.blueGrey, BlendMode.srcIn),
              ),
              label: 'Agencies',
            ),
            const NavigationDestination(
              icon: Icon(
                Icons.map_rounded,
                color: Colors.blueGrey,
              ),
              label: 'Map',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                TImages.ads,
                colorFilter:
                    const ColorFilter.mode(Colors.blueGrey, BlendMode.srcIn),
              ),
              label: 'Annonces',
            ),
            NavigationDestination(
              icon: SvgPicture.asset(
                TImages.inactiveChat,
                colorFilter:
                    const ColorFilter.mode(Colors.blueGrey, BlendMode.srcIn),
              ),
              label: 'Chat',
            ),
          ],
        ),
      ),
      body: Obx(() => _buildBody()),
    );
  }

  Widget _buildBody() {
    switch (selectIndex.value) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const AgenciesScreen();
      case 2:
        return const MapScreen();
      case 3:
        return ArticlesScreen();
      case 4:
        return ChatListScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Stack(
      children: [
        // Contenu principal
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barre de recherche
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1.0,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onTap: () {
                            _isSearchExpanded.value = true;
                          },
                          decoration: InputDecoration(
                            hintText: 'Rechercher une propriété...',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14.0,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey[500],
                              size: 20.0,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                          ),
                          onChanged: (value) {
                            if (value.length >= 3) {
                              _showSearchResults.value = true;
                              searchController.updateQuery(value);
                            } else {
                              _showSearchResults.value = false;
                              searchController.searchResults.clear();
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    // Bouton de filtre
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: Colors.blue[100]!,
                          width: 1.0,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          // _showFilterOverlay.value = true;
                          Get.to(() => const FilterScreen());
                        },
                        icon: Icon(
                          Icons.filter_list,
                          color: Colors.blue[700],
                          size: 24.0,
                        ),
                        tooltip: 'Filtrer',
                        padding: const EdgeInsets.all(12.0),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),

              // Categories Section
              _buildSectionTitle('Catégories'),
              _buildCategories(),

              // Featured Properties
              _buildSectionTitle('Propriétés en vedette'),
              _buildFeaturedProperties(),

              // Latest Properties
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Dernières annonces',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const AllPropertiesScreen());
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Voir tout',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.blue[700],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildLatestProperties(),
            ],
          ),
        ),
        // Overlay de recherche
        _buildSearchOverlay(),
        // Overlay de filtres
        _buildFilterOverlay(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 1.0,
        bottom: 1.0,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Obx(() {
      final state = _categoriesError.value.isNotEmpty
          ? ContentState.error
          : _isLoadingCategories.value
              ? ContentState.loading
              : ContentState.success;

      return ContentLoader(
        height: 120.0,
        state: state,
        errorMessage: _categoriesError.value,
        onRetry: () {
          _categoriesError.value = '';
          _loadCategories();
        },
        child: SizedBox(
          height: 120.0,
          child: categoryController.categories.isEmpty
              ? _buildEmptyState('Aucune catégorie disponible')
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  itemCount: categoryController.categories.length,
                  itemBuilder: (_, index) {
                    final category = categoryController.categories[index];
                    final locale = languageController.locale.languageCode;
                    return _buildCategoryItem(
                      category.icon ?? category.image ?? '',
                      category.getName(locale),
                    );
                  },
                ),
        ),
      );
    });
  }

  // Afficher un état vide avec un message
  Widget _buildEmptyState(String message) {
    return Container(
      height: 100.0,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 32.0,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8.0),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Charger les catégories
  Future<void> _loadCategories() async {
    try {
      _isLoadingCategories.value = true;
      _categoriesError.value = '';
      await categoryController
          .fetchCategories(languageController.locale.languageCode);
    } catch (e) {
      _categoriesError.value = 'Erreur de chargement des catégories';
    } finally {
      _isLoadingCategories.value = false;
    }
  }

  Widget _buildCategoryItem(String image, String label) {
    return Container(
      width: 80.0,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50.0,
            height: 50.0,
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: image.isNotEmpty
                  ? SvgPicture.network(
                      image,
                      width: 28.0,
                      height: 28.0,
                      fit: BoxFit.contain,
                    )
                  : const Icon(Icons.category, size: 28),
            ),
          ),
          const SizedBox(height: 4.0),
          SizedBox(
            width: 75.0,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10.0,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProperties() {
    return Obx(() {
      final state = _featuredError.value.isNotEmpty
          ? ContentState.error
          : articlePromotionController.isLoading.value
              ? ContentState.loading
              : ContentState.success;

      return ContentLoader(
        state: state,
        errorMessage: _featuredError.value,
        onRetry: _loadFeaturedProperties,
        child: SizedBox(
          height: 280.0,
          child: articlePromotionController.promotionProperties.isEmpty
              ? _buildEmptyState('Aucune propriété en vedette')
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  itemCount:
                      articlePromotionController.promotionProperties.length,
                  itemBuilder: (context, index) {
                    final promotion =
                        articlePromotionController.promotionProperties[index];
                    final article = promotion.article;

                    if (article == null) {
                      return const SizedBox.shrink();
                    }

                    final locale = Get.locale?.languageCode ?? 'fr';
                    final name = article.getPropertyByLanguage(locale,
                        propertyType: 'name');

                    // Construire l'URL de l'image
                    String imageUrl = '';
                    if (article.gallery.isNotEmpty) {
                      final galleryItem = article.gallery.first;
                      imageUrl = galleryItem.original;
                    } else if (article.image.isNotEmpty) {
                      imageUrl = article.image;
                    }

                    final status = promotion.status ?? 'publish';
                    final isFeatured = status == 'publish';

                    final isMeuble = article.purpose == 'Rent' &&
                        (article.bookable_type == 'Daily');

                    return Container(
                      width: 220.0,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: isFeatured
                                ? Colors.blue.withValues(alpha: 0.2)
                                : Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: isFeatured
                            ? Border.all(
                                color: Colors.blue.withValues(alpha: 0.3),
                                width: 2.0,
                              )
                            : null,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          // Utiliser la fonction de navigation unifiée
                          navigateToPropertyDetails(article);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16.0),
                                    topRight: Radius.circular(16.0),
                                  ),
                                  child: Image.network(
                                    imageUrl,
                                    height: 140.0,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }
                                      return Container(
                                        height: 140.0,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.blue[400]!),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 140.0,
                                        color: Colors.grey[200],
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                                Icons.photo_library_outlined,
                                                size: 40.0,
                                                color: Colors.grey),
                                            const SizedBox(height: 8.0),
                                            Text(
                                              'Image non disponible',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (isFeatured)
                                  Positioned(
                                    top: 12.0,
                                    right: 12.0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 4.0),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.blue,
                                            Colors.blueAccent
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue
                                                .withValues(alpha: 0.3),
                                            spreadRadius: 1,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 12.0,
                                          ),
                                          SizedBox(width: 4.0),
                                          Text(
                                            'EN VEDETTE',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (isMeuble)
                                  Positioned(
                                    top: 8,
                                    right: 150,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[100],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.orange[300]!),
                                      ),
                                      child: const Text(
                                        'Meublé',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Badge de catégorie
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 2.0),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          border: Border.all(
                                            color: Colors.blue[200]!,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (article.category?.image
                                                    ?.isNotEmpty ??
                                                false)
                                              SvgPicture.network(
                                                article.category!.image!,
                                                height: 12,
                                                width: 12,
                                                colorFilter: ColorFilter.mode(
                                                    Colors.blue[800]!,
                                                    BlendMode.srcIn),
                                              ),
                                            if (article.category?.image
                                                    ?.isNotEmpty ??
                                                false)
                                              const SizedBox(width: 4),
                                            Text(
                                              article.category
                                                      ?.getName(locale) ??
                                                  'Catégorie',
                                              style: TextStyle(
                                                color: Colors.blue[800],
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Prix
                                      Flexible(
                                        child: Obx(() {
                                          final price = article.price ?? 0;
                                          final convertedPrice =
                                              currencyController
                                                  .convertPrice(price);
                                          return Text(
                                            "${convertedPrice.toStringAsFixed(0)} ${currencyController.getCurrentSymbol()}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                              fontSize: 13.0,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.0,
                                      height: 1.2,
                                      color: isFeatured
                                          ? Colors.blue[900]
                                          : Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6.0),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on_outlined,
                                          size: 14.0, color: Colors.grey[400]),
                                      const SizedBox(width: 4.0),
                                      Expanded(
                                        child: Text(
                                          article.structure?.name ??
                                              'Localisation non disponible',
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildFeatureItem(
                                          '${article.bedroom ?? 0} chb',
                                          Icons.king_bed_outlined),
                                      _buildFeatureItem(
                                          '${article.bathroom ?? 0} sdb',
                                          Icons.bathtub_outlined),
                                      if (![
                                        'apartment',
                                        'hostel',
                                        'office',
                                        'store'
                                      ].contains(article.category?.slug))
                                        _buildFeatureItem(
                                            '${article.area?.toInt() ?? 0} m²',
                                            Icons.square_foot),
                                    ],
                                  ),
                                  if (isFeatured)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.visibility,
                                              size: 14.0,
                                              color: Colors.blue[700]),
                                          const SizedBox(width: 4.0),
                                          Text(
                                            '${promotion.prospectsCount ?? 0} vues',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
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
      );
    });
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14.0, color: Colors.blue[400]),
        const SizedBox(width: 4.0),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLatestProperties() {
    return Obx(() {
      final state = _featuredError.value.isNotEmpty
          ? ContentState.error
          : _isLoadingFeatured.value
              ? ContentState.loading
              : ContentState.success;

      return ContentLoader(
        state: state,
        errorMessage: _featuredError.value,
        onRetry: _loadFeaturedProperties,
        child: articlePromotionController.featuredProperties.isEmpty
            ? _buildEmptyState('Aucune propriété récente disponible')
            : ListView.builder(
                itemCount: articlePromotionController.featuredProperties.length,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final property =
                      articlePromotionController.featuredProperties[index];
                  final article = property;

                  if (article == null) {
                    return const SizedBox.shrink();
                  }

                  final locale = Get.locale?.languageCode ?? 'fr';
                  final name = article.getPropertyByLanguage(locale,
                      propertyType: 'name');

                  String imageUrl = '';
                  if (article.gallery.isNotEmpty) {
                    imageUrl = article.gallery.first.original;
                  } else if (article.image.isNotEmpty) {
                    imageUrl = article.image;
                  }

                  final isMeuble = article.purpose == 'Rent' &&
                      (article.bookable_type?.toLowerCase() == 'daily');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    height: 110.0, // Hauteur fixe
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.0),
                        onTap: () {
                          // Utiliser la fonction de navigation unifiée
                          navigateToPropertyDetails(article);
                        },
                        child: Row(
                          children: [
                            // Image à gauche
                            SizedBox(
                              width: 110.0,
                              height: 110.0,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12.0),
                                      bottomLeft: Radius.circular(12.0),
                                    ),
                                    child: Image.network(
                                      imageUrl,
                                      width: 110.0,
                                      height: 110.0,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        width: 110.0,
                                        height: 110.0,
                                        color: Colors.grey[100],
                                        child: const Icon(
                                            Icons.photo_library_outlined,
                                            color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  if (isMeuble)
                                    Positioned(
                                      top: 8,
                                      right: 50,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[100],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.orange[300]!),
                                        ),
                                        child: const Text(
                                          'Meublé',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Détails à droite
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Badge de catégorie
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6.0, vertical: 2.0),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                            border: Border.all(
                                                color: Colors.blue[100]!,
                                                width: 1.0),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (article.category?.image
                                                      ?.isNotEmpty ??
                                                  false)
                                                SvgPicture.network(
                                                  article.category!.image!,
                                                  height: 12,
                                                  width: 12,
                                                  colorFilter: ColorFilter.mode(
                                                      Colors.blue[800]!,
                                                      BlendMode.srcIn),
                                                ),
                                              if (article.category?.image
                                                      ?.isNotEmpty ??
                                                  false)
                                                const SizedBox(width: 4),
                                              Text(
                                                article.category
                                                        ?.getName(locale) ??
                                                    'Catégorie',
                                                style: TextStyle(
                                                  color: Colors.blue[800],
                                                  fontSize: 9.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        // Prix
                                        Obx(() {
                                          final price = article.price ?? 0;
                                          final convertedPrice =
                                              currencyController
                                                  .convertPrice(price);
                                          return Text(
                                            "${convertedPrice.toStringAsFixed(0)} ${currencyController.getCurrentSymbol()}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                              fontSize: 13.0,
                                            ),
                                          );
                                        }),
                                        const SizedBox(height: 4.0),
                                        // Nom de la propriété
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.0,
                                            height: 1.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    // Caractéristiques
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildAmenity(Icons.king_bed_outlined,
                                            '${article.bedroom ?? 0}'),
                                        _buildAmenity(Icons.bathtub_outlined,
                                            '${article.bathroom ?? 0}'),
                                        if (![
                                          'apartment',
                                          'hostel',
                                          'office',
                                          'store'
                                        ].contains(article.category?.slug))
                                          _buildAmenity(Icons.square_foot,
                                              '${article.area?.toInt() ?? 0} m²'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      );
    });
  }

  Widget _buildAmenity(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.0, color: Colors.grey[600]),
        const SizedBox(width: 4.0),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Future<void> _loadFeaturedProperties() async {
    try {
      _isLoadingFeatured.value = true;
      _featuredError.value = '';
      await articlePromotionController.fetchPromotionProperties();
    } catch (e) {
      _featuredError.value =
          'Erreur lors du chargement des propriétés en vedette';
    } finally {
      _isLoadingFeatured.value = false;
    }
  }

  Widget _buildSearchOverlay() {
    return Obx(() {
      if (!_isSearchExpanded.value) return const SizedBox.shrink();

      return Positioned.fill(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Barre de recherche étendue
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        _isSearchExpanded.value = false;
                        _showSearchResults.value = false;
                        _searchController.clear();
                        searchController.updateQuery('');
                        _searchFocusNode.unfocus();
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        autofocus: true,
                        onChanged: (value) {
                          if (value.length >= 3) {
                            _showSearchResults.value = true;
                            searchController.updateQuery(value);
                          } else {
                            _showSearchResults.value = false;
                            searchController.searchResults.clear();
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: 'Rechercher une propriété...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                            top: 8.0,
                            bottom: 8.0,
                          ),
                          isDense: true,
                          hintStyle: TextStyle(
                            height: 1.0,
                            fontSize: 14.0,
                          ),
                          alignLabelWithHint: true,
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          suffixIconConstraints: BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          searchController.updateQuery('');
                          _showSearchResults.value = false;
                        },
                      ),
                  ],
                ),
              ),
              // Résultats de recherche
              Expanded(
                child: Obx(() {
                  if (!_showSearchResults.value) {
                    return const Center(
                      child: Text(
                        'Commencez à taper pour rechercher...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  if (searchController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (searchController.errorMessage.isNotEmpty) {
                    return Center(
                      child: Text(
                        searchController.errorMessage.value,
                        style: TextStyle(color: Colors.red[400]),
                      ),
                    );
                  }

                  if (searchController.searchResults.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucun résultat trouvé',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: searchController.searchResults.length,
                    itemBuilder: (context, index) {
                      final article = searchController.searchResults[index];
                      String imageUrl = '';
                      if (article.gallery.isNotEmpty) {
                        imageUrl = article.gallery.first.original;
                      } else if (article.image.isNotEmpty) {
                        imageUrl = article.image;
                      }

                      final isMeuble = article.purpose == 'Rent' &&
                          (article.bookable_type?.toLowerCase() == 'daily');

                      return GestureDetector(
                        onTap: () {
                          // Utiliser la fonction de navigation unifiée
                          navigateToPropertyDetails(article);
                          _isSearchExpanded.value = false;
                          _showSearchResults.value = false;
                          _searchController.clear();
                          searchController.updateQuery('');
                          _searchFocusNode.unfocus();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              // Image
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8.0),
                                  bottomLeft: Radius.circular(8.0),
                                ),
                                child: Image.network(
                                  imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[100],
                                    child: const Icon(
                                        Icons.photo_library_outlined,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                              // Détails
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article.getPropertyByLanguage(
                                            languageController
                                                .locale.languageCode,
                                            propertyType: "name"),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14.0,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4.0),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on_outlined,
                                              size: 12.0,
                                              color: Colors.grey[400]),
                                          const SizedBox(width: 4.0),
                                          Expanded(
                                            child: Text(
                                              article.structure?.name ??
                                                  'Localisation non disponible',
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4.0),
                                      Obx(() {
                                        final price = article.price ?? 0;
                                        final convertedPrice =
                                            currencyController
                                                .convertPrice(price);
                                        return Text(
                                          "${convertedPrice.toStringAsFixed(0)} ${currencyController.getCurrentSymbol()}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[700],
                                            fontSize: 14.0,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFilterOverlay() {
    final l10n = AppLocalizations.of(context)!;
    return Obx(() {
      if (!_showFilterOverlay.value) return const SizedBox.shrink();

      return Positioned.fill(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // En-tête du filtre
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        _showFilterOverlay.value = false;
                      },
                    ),
                    Expanded(
                      child: Text(
                        l10n.filters,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        filterController.clearFilters();
                      },
                      child: Text(
                        l10n.reset,
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Contenu des filtres
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type de transaction
                      Text(
                        l10n.transaction_type,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Obx(() => Row(
                            children: [
                              Expanded(
                                child: _buildFilterChip(
                                  l10n.for_sale,
                                  filterController.isForSellSelected.value,
                                  () => filterController.toggleForSell(true),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: _buildFilterChip(
                                  l10n.for_rent,
                                  !filterController.isForSellSelected.value,
                                  () => filterController.toggleForSell(false),
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(height: 24.0),

                      // Type de propriété
                      Text(
                        l10n.property_type,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Obx(() => Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: [
                              _buildFilterChip(
                                l10n.all,
                                filterController.selectedPropertyType.value ==
                                    'All',
                                () =>
                                    filterController.selectPropertyType('All'),
                              ),
                              ...categoryController.categories.map((category) {
                                final locale =
                                    languageController.locale.languageCode;
                                final name = category.getName(locale);
                                final id = category.id.toString();
                                return _buildFilterChip(
                                  name,
                                  filterController.selectedPropertyType.value ==
                                      id,
                                  () => filterController.selectPropertyType(id),
                                );
                              }).toList(),
                            ],
                          )),
                      const SizedBox(height: 24.0),

                      // Prix
                      Text(
                        l10n.property_price,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: filterController.minPriceController,
                              onChanged: filterController.updateMinPrice,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Min',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                                suffix: Obx(() => Text(
                                      currencyController.getCurrentSymbol(),
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    )),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: TextField(
                              controller: filterController.maxPriceController,
                              onChanged: filterController.updateMaxPrice,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Max',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                                suffix: Obx(() => Text(
                                      currencyController.getCurrentSymbol(),
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),

                      // Superficie
                      Text(
                        l10n.property_area,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: filterController.minAreaController,
                              onChanged: filterController.updateMinArea,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Min m²',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: TextField(
                              controller: filterController.maxAreaController,
                              onChanged: filterController.updateMaxArea,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Max m²',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),

                      // Période de publication
                      Text(
                        l10n.published,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Obx(() => Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: [
                              _buildFilterChip(
                                l10n.anytime,
                                filterController.selectedPostedSince.value ==
                                    'Anytime',
                                () => filterController
                                    .selectPostedSince('Anytime'),
                              ),
                              _buildFilterChip(
                                l10n.today,
                                filterController.selectedPostedSince.value ==
                                    'Today',
                                () =>
                                    filterController.selectPostedSince('Today'),
                              ),
                              _buildFilterChip(
                                l10n.this_week,
                                filterController.selectedPostedSince.value ==
                                    'ThisWeek',
                                () => filterController
                                    .selectPostedSince('ThisWeek'),
                              ),
                              _buildFilterChip(
                                l10n.this_month,
                                filterController.selectedPostedSince.value ==
                                    'ThisMonth',
                                () => filterController
                                    .selectPostedSince('ThisMonth'),
                              ),
                            ],
                          )),
                      const SizedBox(height: 32.0),

                      // Bouton Appliquer
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await filterController.applyFilters();
                            _showFilterOverlay.value = false;
                            // TODO: Mettre à jour la liste des propriétés avec les résultats filtrés
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            l10n.apply_filters,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[700] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
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
              _authRepository.logout();
              final localStorage = GetStorage();
              _authRepository.logOutBackend(localStorage.read('AUTH_TOKEN'));
              localStorage.remove('AUTH_TOKEN');
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
                _buildLanguageOption('Ar', 'عربي',
                    languageController.locale.languageCode, context),
                _buildLanguageOption('Fr', 'Français',
                    languageController.locale.languageCode, context),
                _buildLanguageOption('En', 'English',
                    languageController.locale.languageCode, context),
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
        languageController.changeLanguage(languageCode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          languageName,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.black,
          ),
        ),
      ),
    );
  }

  // Méthode pour vérifier l'état de connexion
  Future<bool> checkLoginStatus(int index) async {
    final localStorage = GetStorage();
    final CheckAuthController authController = Get.put(CheckAuthController());

    final String? token = await localStorage.read('AUTH_TOKEN');

    if (token == null) {
      _authRepository.logout();
      final localStorage = GetStorage();
      localStorage.remove('AUTH_TOKEN');
      Get.to(() => const LoginPhoneScreen());
      return false;
    }

    final response = await authController.checkToken(token);
    print('Reponse $response');

    if (response) {
      selectIndex.value = index;
      return true;
    } else {
      _authRepository.logout();
      final localStorage = GetStorage();
      localStorage.remove('AUTH_TOKEN');
      Get.to(() => const LoginPhoneScreen());
      return false;
    }
  }

  // Gérer la sélection des onglets
  void onDestinationSelected(int index) async {
    if (index == 3) {
      checkLoginStatus(3);
    } else if (index == 4) {
      checkLoginStatus(4);
    } else {
      selectIndex.value = index;
    }
  }
}

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:immolink_mobile/controllers/home/categories_controller.dart';
import 'package:immolink_mobile/controllers/home/article_promotion_controller.dart';
import 'package:immolink_mobile/controllers/home/search_app_controller.dart';
import 'package:immolink_mobile/controllers/articles/filter_controller.dart';
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'package:immolink_mobile/controllers/currency/currency_controller.dart';
import 'package:immolink_mobile/controllers/communes/commune_controller.dart';
import 'package:immolink_mobile/controllers/communes/district_controller.dart';
import 'package:immolink_mobile/controllers/login/check_auth_controller.dart';
import 'package:immolink_mobile/controllers/login/login_controller.dart';

class InitController extends GetxController {
  static InitController get instance => Get.find();

  final RxBool isInitialized = false.obs;
  final RxDouble progress = 0.0.obs;
  final RxString status = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initializeApp();
  }

  Future<void> initializeApp() async {
    try {
      // Initialiser GetStorage
      await GetStorage.init();
      progress.value = 0.1;
      status.value = 'Initialisation du stockage...';

      // Initialiser les contrôleurs de base
      Get.put(LanguageController());
      progress.value = 0.2;
      status.value = 'Chargement des paramètres de langue...';

      Get.put(CurrencyController());
      progress.value = 0.3;
      status.value = 'Chargement des paramètres de devise...';

      // Initialiser les contrôleurs de l'application
      Get.put(CategoryController());
      progress.value = 0.4;
      status.value = 'Chargement des catégories...';

      Get.put(ArticlePromotionController());
      progress.value = 0.5;
      status.value = 'Chargement des promotions...';

      Get.put(SearchAppController());
      progress.value = 0.6;
      status.value = 'Initialisation de la recherche...';

      Get.put(FilterController());
      progress.value = 0.7;
      status.value = 'Initialisation des filtres...';

      // Initialiser les contrôleurs de navigation
      Get.put(CommuneController());
      Get.put(DistrictController());
      Get.put(CheckAuthController());
      Get.put(LoginController());
      progress.value = 0.8;
      status.value = 'Initialisation des contrôleurs de navigation...';

      // Charger les données initiales
      await _loadInitialData();
      progress.value = 1.0;
      status.value = 'Chargement terminé';

      isInitialized.value = true;
    } catch (e) {
      print('Erreur lors de l\'initialisation: $e');
      status.value = 'Erreur lors du chargement';
      // Gérer l'erreur ici
    }
  }

  Future<void> _loadInitialData() async {
    try {
      final languageController = Get.find<LanguageController>();
      final categoryController = Get.find<CategoryController>();
      final articlePromotionController = Get.find<ArticlePromotionController>();

      // Charger les catégories
      await categoryController
          .fetchCategories(languageController.locale.languageCode);
      progress.value = 0.8;
      status.value = 'Chargement des catégories...';

      // Charger les promotions
      await articlePromotionController.fetchPromotionProperties();
      progress.value = 0.9;
      status.value = 'Chargement des promotions...';
    } catch (e) {
      print('Erreur lors du chargement des données initiales: $e');
      rethrow;
    }
  }
}

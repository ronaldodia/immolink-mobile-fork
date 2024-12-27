import 'package:get/get.dart';

class ArticleFormController extends GetxController {
  // Champs du formulaire
  var nameAr = "".obs;
  var categoryId = 0.obs;
  var authorId = 0.obs;
  var districtId = 0.obs;
  var bookableType = "Daily".obs;
  var purpose = "Rent".obs;
  var price = "".obs;
  var locationLatitude = "".obs;
  var locationLongitude = "".obs;
  var language = "en".obs;
  var area = "".obs;
  var floorPlan = "".obs;
  var status = "publish".obs;
  var bedroom = "".obs;
  var bathroom = "".obs;
  var description = "".obs;
  var gallery = <Map<String, String>>[].obs;
  var image = "".obs;

  // Étape actuelle
  var currentStep = 0.obs;

  // Méthode pour aller à une étape spécifique
  void goToStep(int step) {
    currentStep.value = step;
  }

  // Soumettre le formulaire
  Future<void> submitForm() async {
    final payload = {
      'name_ar': nameAr.value,
      'category_id': categoryId.value,
      'author_id': authorId.value,
      'district_id': districtId.value,
      'bookable_type': bookableType.value,
      'purpose': purpose.value,
      'price': price.value,
      'location_latitude': locationLatitude.value,
      'location_longitude': locationLongitude.value,
      'language': language.value,
      'area': area.value,
      'floor_plan': floorPlan.value,
      'status': status.value,
      'bedroom': bedroom.value,
      'bathroom': bathroom.value,
      'description': description.value,
      'gallery': gallery.map((item) => item).toList(),
      'image': image.value,
    };

    // Exemple de soumission à l'API
    print("Payload envoyé : $payload");
    // Ajoutez ici la logique HTTP POST pour envoyer les données
  }
}


import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'package:immolink_mobile/models/Category.dart';
import 'package:immolink_mobile/utils/image_constants.dart';

class Article {
  final int id;
  final String? name;
  final String? description;
  final String? location_latitude;
  final String? location_longitude;
  final String image;
  final String purpose;
  final String location;
  final int bedroom;
  final int bathroom;
  final int balcony;
  final int? area;
  final double price;
  final Category? category;
  final List<GalleryImage> gallery;

  Article({
    required this.id,
    required this.image,
    required this.name,
    required this.description,
    required this.location_latitude,
    required this.location_longitude,
    required this.purpose,
    required this.location,
    required this.bedroom,
    required this.bathroom,
    required this.balcony,
    required this.area,
    required this.price,
    required this.category,
    required this.gallery,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    final LanguageController language = Get.find();

    String? latitude = json['location_latitude'];
    String? longitude = json['location_longitude'];

    return Article(
      id: json['id'],
      name: json['name_${language.locale.languageCode}'] ?? '', // Gestion de la langue
      description: json['description_${language.locale.languageCode}'] ?? '', // Gestion de la langue
      location_latitude: latitude,
      location_longitude: longitude,
      image: json['image'] ?? '',
      purpose: json['purpose'] ?? '',
      location: (latitude != null && longitude != null)
          ? '$latitude, $longitude'
          : 'Non spécifié', // Construction de location en gérant le cas de valeurs nulles
      price: (json['price'] != null) ? (json['price'] as num).toDouble() : 0.0, // Gestion sécurisée du prix
      bedroom: json['bedroom'] ?? 0,
      bathroom: json['bathroom'] ?? 0,
      balcony: json['balcony'] ?? 0,
      area: json['area'] ?? 0,
      category: json['categories'] != null ? Category.fromJson(json['categories']) : null,
      gallery: (json['gallery'] as List)
          .map((item) => GalleryImage.fromJson(item))
          .toList(),
    );
  }
}


class GalleryImage { // Modèle pour une image dans la galerie
  final String thumbnail;
  final String original;
  final int id;

  GalleryImage({
    required this.thumbnail,
    required this.original,
    required this.id,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      thumbnail: json['thumbnail'],
      original: json['original'],
      id: json['id'],
    );
  }
}

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

  Article( {
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
    required this.gallery
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    final LanguageController language = Get.find();
    return Article(
      id: json['id'],
      name: json['name_${language.locale.languageCode}'], // Vous pouvez changer en fonction de la langue
      description: json['description_${language.locale.languageCode}'] ?? '', // Vous pouvez changer en fonction de la langue
      location_latitude: json['location_latitude'] ?? '', // Vous pouvez changer en fonction de la langue
      location_longitude: json['location_longitude'] ?? '', // Vous pouvez changer en fonction de la langue
      image: json['image'] ?? '', // Vous pouvez changer en fonction de la langue
      purpose: json['purpose'] ?? '', // Vous pouvez changer en fonction de la langue
      location: json['location_latitude'] + ', ' + json['location_longitude'],
      price: json['price'].toDouble() ?? 0,
      bedroom: json['bedroom'] ?? 0,
      bathroom: json['bathroom'] ?? 0,
      balcony: json['balcony'] ?? 0,
      area: json['area'] ?? 0,
      category: json['categories'] != null ? Category.fromJson(json['categories']) : null,
        gallery: (json['gallery'] as List)
            .map((item) => GalleryImage.fromJson(item))
            .toList()
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
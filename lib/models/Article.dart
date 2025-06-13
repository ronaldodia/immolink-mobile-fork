import 'package:immolink_mobile/models/Category.dart';

class Article {
  final int id;
  final Category? category;
  final int district_id;
  final int? structure_id;
  final int author_id;
  final String? name_ar;
  final String? name_fr;
  final String? name_en;
  final String slug;
  final String image;
  final List<Gallery> gallery;
  final String language;
  final String? description_ar;
  final String? description_fr;
  final String? description_en;
  final String? purpose;
  final String? bookable_type;
  final double price;
  final double? sale_price;
  final int reduction_percentage;
  final int? bedroom;
  final int? bathroom;
  final int? balcony;
  final int? area;
  final String? video;
  final String? floor_plan;
  final String location_latitude;
  final String location_longitude;
  final String status;
  final DateTime created_at;
  final DateTime updated_at;
  final Structure? structure;

  Article({
    required this.id,
    this.category,
    required this.district_id,
    this.structure_id,
    required this.author_id,
    this.name_ar,
    this.name_fr,
    this.name_en,
    required this.slug,
    required this.image,
    required this.gallery,
    required this.language,
    this.description_ar,
    this.description_fr,
    this.description_en,
    this.purpose,
    this.bookable_type,
    required this.price,
    this.sale_price,
    required this.reduction_percentage,
    this.bedroom,
    this.bathroom,
    this.balcony,
    this.area,
    this.video,
    this.floor_plan,
    required this.location_latitude,
    required this.location_longitude,
    required this.status,
    required this.created_at,
    required this.updated_at,
    this.structure,
  });

  String getPropertyByLanguage(String language,
      {required String propertyType}) {
    switch (language) {
      case 'ar':
        return propertyType == 'name'
            ? (name_ar ?? '')
            : (description_ar ?? '');
      case 'fr':
        return propertyType == 'name'
            ? (name_fr ?? '')
            : (description_fr ?? '');
      case 'en':
      default:
        return propertyType == 'name'
            ? (name_en ?? '')
            : (description_en ?? '');
    }
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    var galleryList = json['gallery'] as List;
    List<Gallery> gallery =
        galleryList.map((i) => Gallery.fromJson(i)).toList();

    return Article(
      id: json['id'],
      category: json['categories'] != null
          ? Category.fromJson(json['categories'])
          : null,
      district_id: json['district_id'],
      structure_id: json['structure_id'],
      author_id: json['author_id'],
      name_ar: json['name_ar'],
      name_fr: json['name_fr'],
      name_en: json['name_en'],
      slug: json['slug'],
      image: json['image'],
      gallery: gallery,
      language: json['language'],
      description_ar: json['description_ar'],
      description_fr: json['description_fr'],
      description_en: json['description_en'],
      purpose: json['purpose'] ?? '',
      bookable_type: json['bookable_type'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      sale_price: json['sale_price']?.toDouble(),
      reduction_percentage: json['reduction_percentage'] ?? 0,
      bedroom: json['bedroom'],
      bathroom: json['bathroom'],
      balcony: json['balcony'],
      area: json['area'],
      video: json['video'],
      floor_plan: json['floor_plan'],
      location_latitude: json['location_latitude'] ?? '',
      location_longitude: json['location_longitude'] ?? '',
      status: json['status'],
      created_at: DateTime.parse(json['created_at']),
      updated_at: DateTime.parse(json['updated_at']),
      structure: json['structure'] == null
          ? null
          : Structure.fromJson(json['structure']),
    );
  }
}

class Gallery {
  final String thumbnail;
  final String original;
  final int id;

  Gallery({required this.thumbnail, required this.original, required this.id});

  factory Gallery.fromJson(Map<String, dynamic> json) {
    return Gallery(
      thumbnail: json['thumbnail'],
      original: json['original'],
      id: json['id'],
    );
  }
}

class Structure {
  final int id;
  final int owner_id; // This is the owner_id you want to access
  final int district_id;
  final int category_structure_id;
  final String name;
  final String? commercial_register;
  final String slug;
  final String? description;
  final String? cover_image;
  final String logo;
  final int is_active;
  final int is_sponsored;
  final String? contact;
  final String? address;
  final String? settings;
  final DateTime created_at;
  final DateTime updated_at;

  Structure({
    required this.id,
    required this.owner_id,
    required this.district_id,
    required this.category_structure_id,
    required this.name,
    this.commercial_register,
    required this.slug,
    this.description,
    this.cover_image,
    required this.logo,
    required this.is_active,
    required this.is_sponsored,
    this.contact,
    this.address,
    this.settings,
    required this.created_at,
    required this.updated_at,
  });

  factory Structure.fromJson(Map<String, dynamic> json) {
    return Structure(
      id: json['id'],
      owner_id: json['owner_id'],
      // Accessing owner_id here
      district_id: json['district_id'],
      category_structure_id: json['category_structure_id'],
      name: json['name'],
      commercial_register: json['commercial_register'],
      slug: json['slug'],
      description: json['description'],
      cover_image: json['cover_image'],
      logo: json['logo'],
      is_active: json['is_active'],
      is_sponsored: json['is_sponsored'],
      contact: json['contact'],
      address: json['address'],
      settings: json['settings'],
      created_at: DateTime.parse(json['created_at']),
      updated_at: DateTime.parse(json['updated_at']),
    );
  }
}

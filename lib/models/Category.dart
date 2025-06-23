class CategoryType {
  final int id;
  final String name;
  final String slug;
  final String language;
  final String? icon;
  final List<String>? translatedLanguages;

  CategoryType({
    required this.id,
    required this.name,
    required this.slug,
    required this.language,
    this.icon,
    this.translatedLanguages,
  });

  factory CategoryType.fromJson(Map<String, dynamic> json) {
    return CategoryType(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      language: json['language'],
      icon: json['icon'],
      translatedLanguages: json['translated_languages'] != null
          ? List<String>.from(json['translated_languages'])
          : null,
    );
  }
}

class Category {
  final int id;
  final String nameFr;
  final String nameAr;
  final String nameEn;
  final String slug;
  final String? icon;
  final String? image;
  final String? details;
  final int? typeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final CategoryType? type;

  Category({
    required this.id,
    required this.nameFr,
    required this.nameAr,
    required this.nameEn,
    required this.slug,
    this.icon,
    this.image,
    this.details,
    this.typeId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.type,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      nameFr: json['name_fr'] ?? '',
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      slug: json['slug'],
      icon: json['icon'],
      image: json['image'],
      details: json['details'],
      typeId: json['type_id'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'])
          : null,
      type: json['type'] != null ? CategoryType.fromJson(json['type']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_fr': nameFr,
      'name_ar': nameAr,
      'name_en': nameEn,
      'slug': slug,
      'icon': icon,
      'image': image,
      'details': details,
      'type_id': typeId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'type': type != null
          ? {
              'id': type!.id,
              'name': type!.name,
              'slug': type!.slug,
              'language': type!.language,
              'icon': type!.icon,
              'translated_languages': type!.translatedLanguages,
            }
          : null,
    };
  }

  // Helper to get the name in the current locale
  String getName(String locale) {
    switch (locale) {
      case 'ar':
        return nameAr;
      case 'en':
        return nameEn;
      case 'fr':
      default:
        return nameFr;
    }
  }
}

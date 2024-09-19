class Category {
  final int id;
  final String name;
  final String slug;
  final String language;
  final String? icon;
  final String? image;
  final String? details;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<String> translatedLanguages;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.language,
    this.icon,
    this.image,
    this.details,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.translatedLanguages,
  });

  // Factory constructor to create an instance from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      language: json['language'],
      icon: json['icon'],
      image: json['image'],
      details: json['details'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      translatedLanguages: List<String>.from(json['translated_languages']),
    );
  }

  // Method to convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'language': language,
      'icon': icon,
      'image': image,
      'details': details,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'translated_languages': translatedLanguages,
    };
  }
}

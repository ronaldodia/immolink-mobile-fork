class Commune {
  final int id;
  final String name;
  final List<District> districts;

  Commune({required this.id, required this.name, required this.districts});

  factory Commune.fromJson(Map<String, dynamic> json) {
    return Commune(
      id: json['id'],
      name: json['name'],
      districts: (json['districts'] as List)
          .map((e) => District.fromJson(e))
          .toList(),
    );
  }
}

class District {
  final int id;
  final String name;

  District({required this.id, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      name: json['name'],
    );
  }
}

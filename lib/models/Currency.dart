class Currency {
  final int id;
  final String code;
  final String name;
  final String symbol;
  final double exchangeRate;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Currency({
    required this.id,
    required this.code,
    required this.name,
    required this.symbol,
    required this.exchangeRate,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      symbol: json['symbol'],
      exchangeRate: json['exchange_rate'].toDouble(),
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'symbol': symbol,
      'exchange_rate': exchangeRate,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Currency && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

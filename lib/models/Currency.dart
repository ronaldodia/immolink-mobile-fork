class Currency {
  final String code;
  final String name;
  final String imageUrl;
  final double exchangeRate; // This can be updated dynamically
  final String symbol;

  Currency({
    required this.code,
    required this.name,
    required this.imageUrl,
    required this.exchangeRate,
    required this.symbol,
  });
}
class Currency {
  final String code; // "EUR"
  final String name; // "Euro"
  final String flag; // emoji or asset flag
  final bool popular;

  const Currency({
    required this.code,
    required this.name,
    required this.flag,
    this.popular = false,
  });

  factory Currency.fromJson(Map<String, dynamic> j) => Currency(
        code: j['code'] as String,
        name: j['name'] as String,
        flag: j['flag'] as String,
        popular: (j['popular'] as bool?) ?? false,
      );
}

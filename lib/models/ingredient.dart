class Ingredient {
  String name;
  double quantity;
  String unit;

  Ingredient({
    required this.name,
    this.quantity = 0.0,
    this.unit = '',
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'],
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}

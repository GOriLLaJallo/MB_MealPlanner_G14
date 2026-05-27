class ShoppingItem {
  String id;
  String name;
  double quantity;
  String unit;
  bool isPurchased;

  ShoppingItem({
    required this.id,
    required this.name,
    this.quantity = 1.0,
    this.unit = '',
    this.isPurchased = false,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      name: json['name'],
      quantity: (json['quantity'] ?? 1.0).toDouble(),
      unit: json['unit'] ?? '',
      isPurchased: json['isPurchased'] == 1 || json['isPurchased'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'isPurchased': isPurchased ? 1 : 0,
    };
  }
}

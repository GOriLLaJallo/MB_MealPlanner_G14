class PantryItem {
  String id;
  String name;
  String category;
  double quantity;
  String unit;
  DateTime? expiryDate;
  String? notes; // Note aggiuntive

  PantryItem({
    required this.id,
    required this.name,
    this.category = 'Altro',
    this.quantity = 0.0,
    this.unit = '',
    this.expiryDate,
    this.notes,
  });

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id'],
      name: json['name'],
      category: json['category'] ?? 'Altro',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'expiryDate': expiryDate?.toIso8601String(),
      'notes': notes,
    };
  }
}

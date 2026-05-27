class MealPlan {
  String id;
  DateTime date;
  String mealType; // e.g., 'Colazione', 'Pranzo', 'Cena', 'Spuntino'
  String recipeId;
  bool isConsumed;

  MealPlan({
    required this.id,
    required this.date,
    required this.mealType,
    required this.recipeId,
    this.isConsumed = false,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'],
      date: DateTime.parse(json['date']),
      mealType: json['mealType'],
      recipeId: json['recipeId'],
      isConsumed: json['isConsumed'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mealType': mealType,
      'recipeId': recipeId,
      'isConsumed': isConsumed ? 1 : 0,
    };
  }
}

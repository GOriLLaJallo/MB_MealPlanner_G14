import 'dart:convert';
import 'ingredient.dart';

class Recipe {
  String id;
  String name;
  String category;
  int prepTimeMinutes;
  String difficulty; // Facile, Media, Difficile
  int servings; // numero di porzioni
  String instructions;
  List<Ingredient> ingredients;
  String? notes;
  String? imageUrl; // Per l'arricchimento visivo

  Recipe({
    required this.id,
    required this.name,
    required this.category,
    this.prepTimeMinutes = 0,
    this.difficulty = 'Facile',
    this.servings = 1,
    this.instructions = '',
    this.ingredients = const [],
    this.notes,
    this.imageUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<Ingredient> parsedIngredients = [];
    if (json['ingredients'] != null) {
      if (json['ingredients'] is String) {
        // From SQLite
        final List decoded = jsonDecode(json['ingredients']);
        parsedIngredients = decoded.map((i) => Ingredient.fromJson(i as Map<String, dynamic>)).toList();
      } else if (json['ingredients'] is List) {
        // From normal JSON
        parsedIngredients = (json['ingredients'] as List).map((i) => Ingredient.fromJson(i as Map<String, dynamic>)).toList();
      }
    }

    return Recipe(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      prepTimeMinutes: json['prepTimeMinutes'] ?? 0,
      difficulty: json['difficulty'] ?? 'Facile',
      servings: json['servings'] ?? 1,
      instructions: json['instructions'] ?? '',
      ingredients: parsedIngredients,
      notes: json['notes'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'prepTimeMinutes': prepTimeMinutes,
      'difficulty': difficulty,
      'servings': servings,
      'instructions': instructions,
      // Convert list to JSON string for SQLite storage
      'ingredients': jsonEncode(ingredients.map((i) => i.toJson()).toList()),
      'notes': notes,
      'imageUrl': imageUrl,
    };
  }
}

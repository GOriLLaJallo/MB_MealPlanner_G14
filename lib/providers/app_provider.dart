import '../utils/mock_data.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';

import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/pantry_item.dart';
import '../models/meal_plan.dart';
import '../models/shopping_item.dart';
import '../utils/database_helper.dart';

class AppProvider with ChangeNotifier {
  List<Recipe> _recipes = [];
  List<PantryItem> _pantryItems = [];
  List<MealPlan> _mealPlans = [];
  List<ShoppingItem> _shoppingList = [];

  List<Recipe> get recipes => _recipes;
  List<PantryItem> get pantryItems => _pantryItems;
  List<MealPlan> get mealPlans => _mealPlans;
  List<ShoppingItem> get shoppingList => _shoppingList;

  final Uuid _uuid = const Uuid();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  AppProvider() {
    loadData();
  }

  // --- Persistence ---
  Future<void> loadData() async {
    final recipesMap = await _dbHelper.queryAllRows('recipes');
    bool forceReload = false;

    if (recipesMap.isEmpty || recipesMap.length <= 2) {
      forceReload = true;
    }

    if (forceReload) {
      await _dbHelper.clearTable('recipes');
      await _dbHelper.clearTable('pantry_items');
      await _dbHelper.clearTable('meal_plans');
      await _dbHelper.clearTable('shopping_list');
      
      _loadMockData(); // Carica dati fittizi
      await _saveAllDataToDb();
    } else {
      _recipes = recipesMap.map((e) => Recipe.fromJson(e)).toList();

      final pantryMap = await _dbHelper.queryAllRows('pantry_items');
      _pantryItems = pantryMap.map((e) => PantryItem.fromJson(e)).toList();

      final mealPlansMap = await _dbHelper.queryAllRows('meal_plans');
      _mealPlans = mealPlansMap.map((e) => MealPlan.fromJson(e)).toList();

      final shoppingMap = await _dbHelper.queryAllRows('shopping_list');
      _shoppingList = shoppingMap.map((e) => ShoppingItem.fromJson(e)).toList();
    }

    notifyListeners();
  }

  Future<void> _saveAllDataToDb() async {
    try {
      for (var recipe in _recipes) {
        await _dbHelper.insert('recipes', recipe.toJson());
      }
      for (var pantry in _pantryItems) {
        await _dbHelper.insert('pantry_items', pantry.toJson());
      }
      for (var plan in _mealPlans) {
        await _dbHelper.insert('meal_plans', plan.toJson());
      }
      for (var shopping in _shoppingList) {
        await _dbHelper.insert('shopping_list', shopping.toJson());
      }
    } catch (e, stacktrace) {
      debugPrint('Error saving to DB: \$e\\n\$stacktrace');
    }
  }

  // --- Recipes ---
  Future<void> addRecipe(Recipe recipe) async {
    try {
      if (recipe.id.isEmpty) recipe.id = _uuid.v4();
      _recipes.add(recipe);
      await _dbHelper.insert('recipes', recipe.toJson());
      notifyListeners();
    } catch (e, stacktrace) {
      debugPrint('Error inserting recipe: \$e\\n\$stacktrace');
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final index = _recipes.indexWhere((r) => r.id == recipe.id);
    if (index != -1) {
      _recipes[index] = recipe;
      await _dbHelper.update('recipes', recipe.toJson(), 'id', recipe.id);
      notifyListeners();
    }
  }

  Future<void> deleteRecipe(String id) async {
    _recipes.removeWhere((r) => r.id == id);
    await _dbHelper.delete('recipes', 'id', id);
    
    // Remove related meal plans
    final relatedPlans = _mealPlans.where((m) => m.recipeId == id).toList();
    _mealPlans.removeWhere((m) => m.recipeId == id);
    for (var plan in relatedPlans) {
      await _dbHelper.delete('meal_plans', 'id', plan.id);
    }
    
    notifyListeners();
  }

  // --- Pantry ---
  Future<void> addPantryItem(PantryItem item) async {
    if (item.id.isEmpty) item.id = _uuid.v4();
    _pantryItems.add(item);
    await _dbHelper.insert('pantry_items', item.toJson());
    notifyListeners();
  }

  Future<void> updatePantryItem(PantryItem item) async {
    final index = _pantryItems.indexWhere((p) => p.id == item.id);
    if (index != -1) {
      _pantryItems[index] = item;
      await _dbHelper.update('pantry_items', item.toJson(), 'id', item.id);
      notifyListeners();
    }
  }

  Future<void> deletePantryItem(String id) async {
    _pantryItems.removeWhere((p) => p.id == id);
    await _dbHelper.delete('pantry_items', 'id', id);
    notifyListeners();
  }

  // Feature Avanzata: Gestione Scadenze
  List<PantryItem> get expiringPantryItems {
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 3));
    return _pantryItems.where((item) {
      if (item.expiryDate == null) return false;
      return item.expiryDate!.isBefore(threshold);
    }).toList();
  }

  // --- Meal Plans ---
  Future<void> addMealPlan(MealPlan plan) async {
    if (plan.id.isEmpty) plan.id = _uuid.v4();
    _mealPlans.add(plan);
    await _dbHelper.insert('meal_plans', plan.toJson());
    notifyListeners();
  }

  Future<void> deleteMealPlan(String id) async {
    _mealPlans.removeWhere((m) => m.id == id);
    await _dbHelper.delete('meal_plans', 'id', id);
    notifyListeners();
  }

  // Feature Avanzata: Scalo automatico ingredienti
  Future<void> consumeMeal(String mealPlanId) async {
    final index = _mealPlans.indexWhere((m) => m.id == mealPlanId);
    if (index == -1) return;

    final plan = _mealPlans[index];
    if (plan.isConsumed) return; // Già consumato

    plan.isConsumed = true;
    await _dbHelper.update('meal_plans', plan.toJson(), 'id', plan.id);

    final recipe = _recipes.firstWhere(
      (r) => r.id == plan.recipeId, 
      orElse: () => Recipe(id: '', name: '', category: '', prepTimeMinutes: 0, instructions: '', ingredients: [])
    );

    if (recipe.id.isNotEmpty) {
      for (var ing in recipe.ingredients) {
        final key = ing.name.toLowerCase().trim();
        final pantryIndex = _pantryItems.indexWhere((p) => p.name.toLowerCase().trim() == key);
        
        if (pantryIndex != -1) {
          _pantryItems[pantryIndex].quantity -= (ing.quantity * plan.portionsMultiplier);
          if (_pantryItems[pantryIndex].quantity < 0) {
            _pantryItems[pantryIndex].quantity = 0;
          }
          await _dbHelper.update('pantry_items', _pantryItems[pantryIndex].toJson(), 'id', _pantryItems[pantryIndex].id);
        }
      }
    }

    notifyListeners();
  }

  // --- Shopping List ---
  Future<void> addShoppingItem(ShoppingItem item) async {
    if (item.id.isEmpty) item.id = _uuid.v4();
    _shoppingList.add(item);
    await _dbHelper.insert('shopping_list', item.toJson());
    notifyListeners();
  }

  Future<void> updateShoppingItem(ShoppingItem item) async {
    final index = _shoppingList.indexWhere((s) => s.id == item.id);
    if (index != -1) {
      _shoppingList[index] = item;
      await _dbHelper.update('shopping_list', item.toJson(), 'id', item.id);
      notifyListeners();
    }
  }

  Future<void> deleteShoppingItem(String id) async {
    _shoppingList.removeWhere((s) => s.id == id);
    await _dbHelper.delete('shopping_list', 'id', id);
    notifyListeners();
  }

  Future<void> toggleShoppingItemPurchased(String id) async {
    final index = _shoppingList.indexWhere((s) => s.id == id);
    if (index != -1) {
      _shoppingList[index].isPurchased = !_shoppingList[index].isPurchased;
      await _dbHelper.update('shopping_list', _shoppingList[index].toJson(), 'id', id);
      notifyListeners();
    }
  }

  // Feature Avanzata: Generazione Automatica Lista della Spesa
  Future<void> generateShoppingList(DateTime startDate, DateTime endDate) async {
    Map<String, double> requiredIngredients = {};
    Map<String, String> ingredientUnits = {};

    // 1. Raccogli ingredienti necessari dai meal plan
    final plansInRange = _mealPlans.where((m) =>
        m.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        m.date.isBefore(endDate.add(const Duration(days: 1))));

    for (var plan in plansInRange) {
      final recipe = _recipes.firstWhere((r) => r.id == plan.recipeId, orElse: () => Recipe(id: '', name: '', category: '', prepTimeMinutes: 0, instructions: '', ingredients: []));
      if (recipe.id.isEmpty) continue;

      for (var ing in recipe.ingredients) {
        final key = ing.name.toLowerCase().trim();
        requiredIngredients[key] = (requiredIngredients[key] ?? 0.0) + (ing.quantity * plan.portionsMultiplier);
        ingredientUnits[key] = ing.unit;
      }
    }

    // 2. Sottrai ingredienti già in dispensa
    for (var pantry in _pantryItems) {
      final key = pantry.name.toLowerCase().trim();
      if (requiredIngredients.containsKey(key)) {
        requiredIngredients[key] = requiredIngredients[key]! - pantry.quantity;
      }
    }

    // 2.5 Sottrai ingredienti già nella lista della spesa
    for (var shoppingItem in _shoppingList) {
      final key = shoppingItem.name.toLowerCase().trim();
      if (requiredIngredients.containsKey(key)) {
        requiredIngredients[key] = requiredIngredients[key]! - shoppingItem.quantity;
      }
    }

    // 3. Aggiungi alla lista della spesa
    for (var entry in requiredIngredients.entries) {
      final name = entry.key;
      final quantity = entry.value;
      if (quantity > 0) {
        // Controlla se c'è già nella lista
        final existingIndex = _shoppingList.indexWhere((s) => s.name.toLowerCase().trim() == name);
        if (existingIndex != -1) {
          _shoppingList[existingIndex].quantity += quantity;
          await _dbHelper.update('shopping_list', _shoppingList[existingIndex].toJson(), 'id', _shoppingList[existingIndex].id);
        } else {
          final newItem = ShoppingItem(
            id: _uuid.v4(),
            name: _capitalize(name),
            quantity: quantity,
            unit: ingredientUnits[name] ?? '',
          );
          _shoppingList.add(newItem);
          await _dbHelper.insert('shopping_list', newItem.toJson());
        }
      }
    }

    notifyListeners();
  }

  Future<void> transferPurchasedToPantry() async {
    final purchasedItems = _shoppingList.where((s) => s.isPurchased).toList();
    
    for (var item in purchasedItems) {
      // Check if already in pantry
      final existingIndex = _pantryItems.indexWhere((p) => p.name.toLowerCase().trim() == item.name.toLowerCase().trim());
      if (existingIndex != -1) {
        _pantryItems[existingIndex].quantity += item.quantity;
        await _dbHelper.update('pantry_items', _pantryItems[existingIndex].toJson(), 'id', _pantryItems[existingIndex].id);
      } else {
        final newItem = PantryItem(
          id: _uuid.v4(),
          name: item.name,
          quantity: item.quantity,
          unit: item.unit,
          category: 'Acquisti Recenti',
        );
        _pantryItems.add(newItem);
        await _dbHelper.insert('pantry_items', newItem.toJson());
      }
      
      // Remove from shopping list
      _shoppingList.removeWhere((s) => s.id == item.id);
      await _dbHelper.delete('shopping_list', 'id', item.id);
    }
    
    notifyListeners();
  }

  List<Recipe> getSafeRecipes() {
    final now = DateTime.now();
    return _recipes.where((recipe) {
      for (var ing in recipe.ingredients) {
        final matchingItems = _pantryItems.where((p) => p.name.toLowerCase().trim() == ing.name.toLowerCase().trim());
        if (matchingItems.isNotEmpty) {
          final allExpired = matchingItems.every((p) => p.expiryDate != null && p.expiryDate!.isBefore(now));
          if (allExpired) return false;
        }
      }
      return true;
    }).toList();
  }

  List<Recipe> getSuggestableRecipes() {
    // Suggerisci ricette per cui si ha almeno il 70% degli ingredienti (non scaduti) in dispensa
    List<Recipe> suggestable = [];
    final now = DateTime.now();
    final safe = getSafeRecipes();
    
    for (var recipe in safe) {
      if (recipe.ingredients.isEmpty) continue;
      int availableCount = 0;
      for (var ing in recipe.ingredients) {
        final hasIng = _pantryItems.any((p) => 
          p.name.toLowerCase().trim() == ing.name.toLowerCase().trim() && 
          p.quantity >= ing.quantity &&
          (p.expiryDate == null || !p.expiryDate!.isBefore(now)));
        if (hasIng) availableCount++;
      }
      if (availableCount == recipe.ingredients.length) {
        suggestable.add(recipe);
      }
    }
    return suggestable;
  }

  String _capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;

  // --- Mock Data ---
  void _loadMockData() {
    final payload = MockData.generate();
    _recipes = payload.recipes;
    _pantryItems = payload.pantryItems;
    _mealPlans = payload.mealPlans;
  }
}

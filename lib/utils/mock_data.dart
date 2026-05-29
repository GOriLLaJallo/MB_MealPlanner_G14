import 'package:uuid/uuid.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../models/pantry_item.dart';
import '../models/meal_plan.dart';

class MockDataPayload {
  final List<Recipe> recipes;
  final List<PantryItem> pantryItems;
  final List<MealPlan> mealPlans;

  MockDataPayload(this.recipes, this.pantryItems, this.mealPlans);
}

class MockData {
  static MockDataPayload generate() {
    const _uuid = Uuid();
    final r1 = Recipe(
      id: _uuid.v4(),
      name: 'Porridge di Avena',
      category: 'Colazione',
      prepTimeMinutes: 10,
      difficulty: 'Facile',
      servings: 1,
      notes: 'Ottimo per iniziare la giornata con energia.',
      instructions: '1. Cuocere l\'avena nel latte o acqua.\n2. Aggiungere frutta fresca e miele.',
      ingredients: [
        Ingredient(name: 'Avena', quantity: 50, unit: 'g'),
        Ingredient(name: 'Latte', quantity: 200, unit: 'ml'),
        Ingredient(name: 'Miele', quantity: 20, unit: 'g'),
      ],
    );
    final r2 = Recipe(
      id: _uuid.v4(),
      name: 'Toast Avocado e Uovo',
      category: 'Colazione',
      prepTimeMinutes: 10,
      difficulty: 'Media',
      servings: 1,
      notes: 'Usa pane ai cereali per un gusto migliore.',
      instructions: '1. Tostare il pane.\n2. Schiacciare l\'avocado.\n3. Cuocere l\'uovo in camicia o sodo.\n4. Comporre il toast.',
      ingredients: [
        Ingredient(name: 'Pane Integrale', quantity: 60, unit: 'g'),
        Ingredient(name: 'Avocado', quantity: 75, unit: 'g'),
        Ingredient(name: 'Uova', quantity: 50, unit: 'g'),
      ],
    );
    final r3 = Recipe(
      id: _uuid.v4(),
      name: 'Insalata di Quinoa',
      category: 'Primo',
      prepTimeMinutes: 25,
      difficulty: 'Facile',
      servings: 2,
      instructions: '1. Cuocere la quinoa.\n2. Tagliare i pomodorini e le verdure a cubetti.\n3. Mescolare tutto e condire con olio e limone.',
      ingredients: [
        Ingredient(name: 'Quinoa', quantity: 80, unit: 'g'),
        Ingredient(name: 'Pomodorini', quantity: 100, unit: 'g'),
        Ingredient(name: 'Olio d\'oliva', quantity: 15, unit: 'ml'),
      ],
    );
    final r4 = Recipe(
      id: _uuid.v4(),
      name: 'Salmone al Forno con Asparagi',
      category: 'Secondo',
      prepTimeMinutes: 30,
      difficulty: 'Media',
      servings: 2,
      notes: 'Puoi aggiungere fettine di limone sopra il salmone durante la cottura.',
      instructions: '1. Disporre il salmone e gli asparagi su una teglia.\n2. Condire con sale, pepe e limone.\n3. Cuocere in forno a 200°C per 20 minuti.',
      ingredients: [
        Ingredient(name: 'Salmone', quantity: 200, unit: 'g'),
        Ingredient(name: 'Asparagi', quantity: 150, unit: 'g'),
        Ingredient(name: 'Limone', quantity: 25, unit: 'ml'),
      ],
    );
    final r5 = Recipe(
      id: _uuid.v4(),
      name: 'Yogurt Greco con Noci e Miele',
      category: 'Spuntino',
      prepTimeMinutes: 5,
      difficulty: 'Facile',
      servings: 1,
      instructions: '1. Versare lo yogurt in una tazza.\n2. Aggiungere le noci tritate e il miele.',
      ingredients: [
        Ingredient(name: 'Yogurt Greco', quantity: 150, unit: 'g'),
        Ingredient(name: 'Noci', quantity: 20, unit: 'g'),
        Ingredient(name: 'Miele', quantity: 10, unit: 'g'),
      ],
    );
    final r6 = Recipe(
      id: _uuid.v4(),
      name: 'Mandorle Tostate',
      category: 'Spuntino',
      prepTimeMinutes: 5,
      difficulty: 'Facile',
      servings: 1,
      notes: 'Non salare troppo se usate come spuntino frequente.',
      instructions: '1. Mangiare le mandorle tostate come spuntino.',
      ingredients: [
        Ingredient(name: 'Mandorle', quantity: 30, unit: 'g'),
      ],
    );

    final r7 = Recipe(
      id: _uuid.v4(),
      name: 'Spaghetti al Pomodoro',
      category: 'Primo',
      prepTimeMinutes: 20,
      difficulty: 'Facile',
      servings: 2,
      instructions: '1. Cuocere gli spaghetti in acqua salata.\n2. Preparare il sugo con passata e basilico.\n3. Scolare la pasta e saltare nel sugo.',
      ingredients: [
        Ingredient(name: 'Spaghetti', quantity: 200, unit: 'g'),
        Ingredient(name: 'Passata di Pomodoro', quantity: 250, unit: 'ml'),
        Ingredient(name: 'Basilico', quantity: 5, unit: 'g'),
      ],
    );
    final r8 = Recipe(
      id: _uuid.v4(),
      name: 'Pollo con Patate',
      category: 'Secondo',
      prepTimeMinutes: 45,
      difficulty: 'Media',
      servings: 4,
      instructions: '1. Tagliare il pollo a pezzi e le patate a cubetti.\n2. Condire con olio, rosmarino e sale.\n3. Cuocere in forno a 200°C per 40 minuti.',
      ingredients: [
        Ingredient(name: 'Pollo', quantity: 600, unit: 'g'),
        Ingredient(name: 'Patate', quantity: 500, unit: 'g'),
        Ingredient(name: 'Rosmarino', quantity: 10, unit: 'g'),
      ],
    );
    final r9 = Recipe(
      id: _uuid.v4(),
      name: 'Smoothie Banana e Burro di Arachidi',
      category: 'Spuntino',
      prepTimeMinutes: 5,
      difficulty: 'Facile',
      servings: 1,
      instructions: '1. Inserire banana, latte e burro di arachidi nel frullatore.\n2. Frullare fino a ottenere un composto liscio.',
      ingredients: [
        Ingredient(name: 'Banana', quantity: 120, unit: 'g'),
        Ingredient(name: 'Latte', quantity: 200, unit: 'ml'),
        Ingredient(name: 'Burro di Arachidi', quantity: 20, unit: 'g'),
      ],
    );
    List<Recipe> recipes = [r1, r2, r3, r4, r5, r6, r7, r8, r9];

    List<PantryItem> pantryItems = [
      PantryItem(id: _uuid.v4(), name: 'Avena', category: 'Carboidrati', quantity: 500, unit: 'g', expiryDate: DateTime.now().add(const Duration(days: 90))),
      PantryItem(id: _uuid.v4(), name: 'Avocado', category: 'Verdura', quantity: 150, unit: 'g', expiryDate: DateTime.now().add(const Duration(days: 2)), notes: 'Maturo, da usare presto!'), 
      PantryItem(id: _uuid.v4(), name: 'Uova', category: 'Latticini', quantity: 300, unit: 'g', expiryDate: DateTime.now().add(const Duration(days: 10))),
      PantryItem(id: _uuid.v4(), name: 'Quinoa', category: 'Carboidrati', quantity: 300, unit: 'g', expiryDate: DateTime.now().add(const Duration(days: 180))),
      PantryItem(id: _uuid.v4(), name: 'Salmone', category: 'Pesce', quantity: 0, unit: 'g', expiryDate: null, notes: 'Surgelato o fresco'), 
      PantryItem(id: _uuid.v4(), name: 'Asparagi', category: 'Verdura', quantity: 200, unit: 'g', expiryDate: DateTime.now().subtract(const Duration(days: 1)), notes: 'Forse da buttare'), 
      PantryItem(id: _uuid.v4(), name: 'Yogurt Greco', category: 'Latticini', quantity: 500, unit: 'g', expiryDate: DateTime.now().add(const Duration(days: 15))),
      PantryItem(id: _uuid.v4(), name: 'Noci', category: 'Frutta secca', quantity: 200, unit: 'g', expiryDate: DateTime.now().add(const Duration(days: 60))),
      PantryItem(id: _uuid.v4(), name: 'Miele', category: 'Pasticceria', quantity: 250, unit: 'g', expiryDate: DateTime.now().add(const Duration(days: 365))),
      PantryItem(id: _uuid.v4(), name: 'Mandorle', category: 'Frutta secca', quantity: 200, unit: 'g', expiryDate: DateTime.now().add(const Duration(days: 120))),
      PantryItem(id: _uuid.v4(), name: 'Spaghetti', category: 'Carboidrati', quantity: 1000, unit: 'g', expiryDate: DateTime.now().add(const Duration(days: 300))),
      PantryItem(id: _uuid.v4(), name: 'Passata di Pomodoro', category: 'Altro', quantity: 500, unit: 'ml', expiryDate: DateTime.now().add(const Duration(days: 180))),
      PantryItem(id: _uuid.v4(), name: 'Pollo', category: 'Carne', quantity: 800, unit: 'g', expiryDate: DateTime.now().add(const Duration(days: 3))),
      PantryItem(id: _uuid.v4(), name: 'Patate', category: 'Verdura', quantity: 1000, unit: 'g', expiryDate: DateTime.now().add(const Duration(days: 30))),
    ];

    final today = DateTime.now();
    List<MealPlan> mealPlans = [
      MealPlan(id: _uuid.v4(), date: today, mealType: 'Colazione', recipeId: r1.id),
      MealPlan(id: _uuid.v4(), date: today, mealType: 'Spuntino', recipeId: r5.id),
      MealPlan(id: _uuid.v4(), date: today, mealType: 'Pranzo', recipeId: r3.id),
      MealPlan(id: _uuid.v4(), date: today, mealType: 'Cena', recipeId: r4.id),
      MealPlan(id: _uuid.v4(), date: today.add(const Duration(days: 1)), mealType: 'Colazione', recipeId: r2.id),
      MealPlan(id: _uuid.v4(), date: today.add(const Duration(days: 1)), mealType: 'Spuntino', recipeId: r6.id),
      MealPlan(id: _uuid.v4(), date: today.add(const Duration(days: 1)), mealType: 'Pranzo', recipeId: r7.id),
      MealPlan(id: _uuid.v4(), date: today.add(const Duration(days: 1)), mealType: 'Cena', recipeId: r8.id),
      MealPlan(id: _uuid.v4(), date: today.add(const Duration(days: 2)), mealType: 'Spuntino', recipeId: r9.id),
    ];
    return MockDataPayload(recipes, pantryItems, mealPlans);
  }
}

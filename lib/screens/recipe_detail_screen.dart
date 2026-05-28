import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'recipe_form_screen.dart';
import '../utils/theme.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        // Safe check if recipe exists
        final recipeIndex = provider.recipes.indexWhere((r) => r.id == recipeId);
        if (recipeIndex == -1) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Ricetta non trovata.')));
        }
        final recipe = provider.recipes[recipeIndex];
        
        return Scaffold(
          appBar: AppBar(
            title: Text(recipe.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeFormScreen(recipe: recipe)));
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  provider.deleteRecipe(recipeId);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Chip(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        label: Text(recipe.category), 
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.12), 
                        labelStyle: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide.none),
                      ),
                      Chip(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        label: Text('${recipe.prepTimeMinutes} min'), 
                        avatar: const Icon(Icons.timer, size: 18),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
                      ),
                      Chip(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        label: Text(recipe.difficulty), 
                        avatar: const Icon(Icons.fitness_center, size: 18),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
                      ),
                      Chip(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        label: Text('${recipe.servings} porzioni'), 
                        avatar: const Icon(Icons.people, size: 18),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text('Ingredienti', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Column(
                      children: recipe.ingredients.map((i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                              child: Icon(Icons.restaurant, size: 14, color: AppTheme.primaryColor),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: Text(i.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                            Text('${i.quantity} ${i.unit}', style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Text('Istruzioni', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Text(recipe.instructions, style: const TextStyle(fontSize: 16, height: 1.8)),
                  ),
                  if (recipe.notes != null && recipe.notes!.isNotEmpty) ...[
                    const SizedBox(height: 36),
                    Text('Note aggiuntive', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline, color: AppTheme.accentColor),
                          const SizedBox(width: 12),
                          Expanded(child: Text(recipe.notes!, style: TextStyle(fontSize: 15, color: Colors.green.shade900, fontStyle: FontStyle.italic, height: 1.5))),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

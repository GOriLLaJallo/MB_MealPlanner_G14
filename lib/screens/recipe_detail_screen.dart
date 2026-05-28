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
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                stretch: true,
                backgroundColor: AppTheme.primaryColor,
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeFormScreen(recipe: recipe)));
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.8), shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        provider.deleteRecipe(recipeId);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 40, right: 20),
                  title: Text(recipe.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black87, blurRadius: 10)])),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildFallbackHeader(context),
                      // Gradient Overlay for text readability
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -30),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFallbackHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: const Center(
        child: Icon(Icons.restaurant, size: 80, color: Colors.white54),
      ),
    );
  }
}

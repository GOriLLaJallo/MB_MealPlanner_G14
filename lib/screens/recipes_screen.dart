import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/recipe.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';
import '../utils/theme.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Tutte';
  double _maxPrepTime = 120; // in minuti (es. max 2 ore)
  final List<String> _categories = ['Tutte', 'Colazione', 'Spuntino', 'Primo', 'Secondo', 'Contorno', 'Dolce', 'Altro'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ricette'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeFormScreen()));
            },
          )
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          List<Recipe> filtered = provider.recipes.where((r) {
            final matchesSearch = r.name.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesCategory = _selectedCategory == 'Tutte' || r.category == _selectedCategory;
            final matchesTime = r.prepTimeMinutes <= _maxPrepTime;
            return matchesSearch && matchesCategory && matchesTime;
          }).toList();
          
          filtered.sort((a, b) {
            int catCompare = a.category.compareTo(b.category);
            if (catCompare != 0) return catCompare;
            return a.name.compareTo(b.name);
          });

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Cerca ricetta...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                        value: _selectedCategory,
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Tempo Max: ${_maxPrepTime.toInt()} min'),
                    Expanded(
                      child: Slider(
                        value: _maxPrepTime,
                        min: 15,
                        max: 120,
                        divisions: 7, // 15, 30, 45, 60, 75, 90, 105, 120
                        label: '${_maxPrepTime.toInt()} min',
                        onChanged: (val) {
                          setState(() => _maxPrepTime = val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant_menu, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text('Nessuna ricetta trovata.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final recipe = filtered[index];
                          
                          bool showHeader = false;
                          if (index == 0 || filtered[index - 1].category != recipe.category) {
                            showHeader = true;
                          }
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showHeader)
                                Container(
                                  width: double.infinity,
                                  color: Colors.grey.shade200,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  margin: EdgeInsets.only(top: index == 0 ? 0 : 8),
                                  child: Text(
                                    recipe.category.toUpperCase(),
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.restaurant, color: AppTheme.primaryColor),
                              ),
                              title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Wrap(
                                  spacing: 12,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.fitness_center, size: 14, color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text(recipe.difficulty, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.timer, size: 14, color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text('${recipe.prepTimeMinutes} min', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                      ],
                                    ),

                                  ],
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipeId: recipe.id)));
                              },
                            ),
                          ),
                        ],
                      );
                    },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeFormScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

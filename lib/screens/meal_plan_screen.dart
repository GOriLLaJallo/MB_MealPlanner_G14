import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/meal_plan.dart';
import '../models/recipe.dart';
import 'recipe_detail_screen.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  DateTime _selectedDate = DateTime.now();

  void _showMealForm(BuildContext context, [MealPlan? plan]) {
    final recipes = Provider.of<AppProvider>(context, listen: false).recipes;
    if (recipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aggiungi prima delle ricette!')));
      return;
    }

    String? selectedRecipeId = plan?.recipeId ?? recipes.first.id;
    String selectedMealType = plan?.mealType ?? 'Pranzo';
    DateTime selectedPlanDate = plan?.date ?? _selectedDate;

    final mealTypes = ['Colazione', 'Pranzo', 'Cena', 'Spuntino'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan == null ? 'Pianifica Pasto' : 'Modifica Pasto', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Ricetta'),
                  value: selectedRecipeId,
                  items: recipes.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (val) => setModalState(() => selectedRecipeId = val),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Tipo Pasto'),
                  value: selectedMealType,
                  items: mealTypes.map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (val) => setModalState(() => selectedMealType = val!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text('Data: ${DateFormat('dd/MM/yyyy').format(selectedPlanDate)}'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedPlanDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setModalState(() => selectedPlanDate = date);
                        }
                      },
                      child: const Text('Cambia Data'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedRecipeId == null) return;
                      final newPlan = MealPlan(
                        id: plan?.id ?? '',
                        date: selectedPlanDate,
                        mealType: selectedMealType,
                        recipeId: selectedRecipeId!,
                      );
                      
                      if (plan == null) {
                        Provider.of<AppProvider>(context, listen: false).addMealPlan(newPlan);
                      } else {
                        Provider.of<AppProvider>(context, listen: false).deleteMealPlan(plan.id);
                        Provider.of<AppProvider>(context, listen: false).addMealPlan(newPlan);
                      }
                      Navigator.pop(ctx);
                    },
                    child: const Text('Salva Pianificazione'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pianificazione Pasti')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          // Raggruppa i pasti per giorno
          Map<String, List<MealPlan>> grouped = {};
          for (var p in provider.mealPlans) {
            final dateKey = DateFormat('yyyy-MM-dd').format(p.date);
            if (grouped[dateKey] == null) grouped[dateKey] = [];
            grouped[dateKey]!.add(p);
          }
          
          final sortedKeys = grouped.keys.toList()..sort();

          if (sortedKeys.isEmpty) {
            return const Center(child: Text('Nessun pasto pianificato.'));
          }

          return ListView.builder(
            itemCount: sortedKeys.length,
            itemBuilder: (context, index) {
              final dateStr = sortedKeys[index];
              final plans = grouped[dateStr]!;
              final date = DateTime.parse(dateStr);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      DateFormat('EEEE, d MMMM yyyy', 'it_IT').format(date).toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...plans.map((p) {
                    final recipe = provider.recipes.firstWhere((r) => r.id == p.recipeId, orElse: () => Recipe(id: '', name: 'Ricetta Rimossa', category: '', prepTimeMinutes: 0, instructions: '', ingredients: []));
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Icon(Icons.restaurant, color: Theme.of(context).primaryColor),
                        ),
                        title: Text(recipe.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(p.mealType),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                p.isConsumed ? Icons.check_circle : Icons.check_circle_outline,
                                color: p.isConsumed ? Colors.grey : Colors.green,
                              ),
                              onPressed: p.isConsumed ? null : () {
                                provider.consumeMeal(p.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Pasto consumato e ingredienti scalati!')),
                                );
                              },
                              tooltip: p.isConsumed ? 'Già consumato' : 'Consuma',
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showMealForm(context, p),
                              tooltip: 'Modifica Pasto',
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => provider.deleteMealPlan(p.id),
                              tooltip: 'Rimuovi Pasto',
                            ),
                          ],
                        ),
                        onTap: () {
                          if (recipe.id.isNotEmpty) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipeId: recipe.id)));
                          }
                        },
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMealForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

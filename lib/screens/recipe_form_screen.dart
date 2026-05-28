import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';

class RecipeFormScreen extends StatefulWidget {
  final Recipe? recipe;
  const RecipeFormScreen({super.key, this.recipe});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _category;
  late int _prepTime;
  late String _instructions;
  late String _difficulty;
  late int _servings;
  late String _notes;
  List<Ingredient> _ingredients = [];

  final List<String> _categories = ['Colazione', 'Spuntino', 'Primo', 'Secondo', 'Contorno', 'Dolce', 'Altro'];
  final List<String> _difficulties = ['Facile', 'Media', 'Difficile'];

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _name = widget.recipe!.name;
      _category = widget.recipe!.category;
      _prepTime = widget.recipe!.prepTimeMinutes;
      _instructions = widget.recipe!.instructions;
      _difficulty = widget.recipe!.difficulty;
      _servings = widget.recipe!.servings;
      _notes = widget.recipe!.notes ?? '';
      _ingredients = widget.recipe!.ingredients.map((i) => Ingredient(name: i.name, quantity: i.quantity, unit: i.unit)).toList();
    } else {
      _name = '';
      _category = 'Primo';
      _prepTime = 30;
      _instructions = '';
      _difficulty = 'Facile';
      _servings = 1;
      _notes = '';
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newRecipe = Recipe(
        id: widget.recipe?.id ?? '',
        name: _name,
        category: _category,
        prepTimeMinutes: _prepTime,
        difficulty: _difficulty,
        servings: _servings,
        instructions: _instructions,
        notes: _notes.isNotEmpty ? _notes : null,
        ingredients: _ingredients.where((i) => i.name.isNotEmpty).toList(),
      );

      if (widget.recipe == null) {
        Provider.of<AppProvider>(context, listen: false).addRecipe(newRecipe);
      } else {
        Provider.of<AppProvider>(context, listen: false).updateRecipe(newRecipe);
      }
      Navigator.pop(context);
    }
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(Ingredient(name: '', quantity: 0, unit: ''));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.recipe == null ? 'Nuova Ricetta' : 'Modifica Ricetta')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nome Ricetta'),
                validator: (val) => val == null || val.isEmpty ? 'Campo obbligatorio' : null,
                onSaved: (val) => _name = val!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _category,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (val) => setState(() => _category = val!),
                onSaved: (val) => _category = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _prepTime.toString(),
                decoration: const InputDecoration(labelText: 'Tempo di prep. (min)'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || int.tryParse(val) == null ? 'Inserisci un numero valido' : null,
                onSaved: (val) => _prepTime = int.parse(val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _difficulty,
                decoration: const InputDecoration(labelText: 'Difficoltà'),
                items: _difficulties.map((d) => DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (val) => setState(() => _difficulty = val!),
                onSaved: (val) => _difficulty = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _servings.toString(),
                decoration: const InputDecoration(labelText: 'Porzioni'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || int.tryParse(val) == null ? 'Inserisci un numero valido' : null,
                onSaved: (val) => _servings = int.parse(val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _instructions,
                decoration: const InputDecoration(labelText: 'Istruzioni'),
                maxLines: 4,
                onSaved: (val) => _instructions = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(labelText: 'Note aggiuntive (opzionale)'),
                maxLines: 2,
                onSaved: (val) => _notes = val ?? '',
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ingredienti', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(onPressed: _addIngredient, icon: const Icon(Icons.add), label: const Text('Aggiungi')),
                ],
              ),
              ..._ingredients.asMap().entries.map((e) {
                final idx = e.key;
                final ing = e.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          initialValue: ing.name,
                          decoration: const InputDecoration(labelText: 'Nome', contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                          onChanged: (val) => ing.name = val,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: ing.quantity.toString(),
                          decoration: const InputDecoration(labelText: 'Q.tà', contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                          keyboardType: TextInputType.number,
                          onChanged: (val) => ing.quantity = double.tryParse(val) ?? 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: ing.unit,
                          decoration: const InputDecoration(labelText: 'Unità', contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                          onChanged: (val) => ing.unit = val,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => setState(() => _ingredients.removeAt(idx)),
                      )
                    ],
                  ),
                );
              }),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Salva Ricetta', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/pantry_item.dart';

const List<String> pantryCategories = [
  'Frutta',
  'Verdura',
  'Carne',
  'Pesce',
  'Uova',
  'Latticini',
  'Legumi',
  'Carboidrati',
  'Frutta secca',
  'Pasticceria',
  'Liquidi',
  'Vegan',
  'Altro'
];

class PantryScreen extends StatefulWidget {
  final bool initialShowOnlyExpiring;

  const PantryScreen({
    super.key,
    this.initialShowOnlyExpiring = false,
  });

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  String _searchQuery = '';
  late bool _showOnlyExpiring;

  @override
  void initState() {
    super.initState();
    _showOnlyExpiring = widget.initialShowOnlyExpiring;
  }

  void _showItemForm(BuildContext context, [PantryItem? item]) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final quantityCtrl = TextEditingController(text: item?.quantity.toString() ?? '');
    final notesCtrl = TextEditingController(text: item?.notes ?? '');
    String selectedCategory = item?.category ?? 'Altro';
    if (!pantryCategories.contains(selectedCategory)) {
      selectedCategory = 'Altro';
    }
    String selectedUnit = item?.unit ?? 'g';
    if (selectedUnit != 'g' && selectedUnit != 'ml') selectedUnit = 'g';
    DateTime? selectedDate = item?.expiryDate;

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
                Text(item == null ? 'Nuovo Prodotto' : 'Modifica Prodotto', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nome Prodotto'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: pantryCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() => selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityCtrl,
                        decoration: const InputDecoration(labelText: 'Quantità'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedUnit,
                        decoration: const InputDecoration(labelText: 'Unità'),
                        items: const [
                          DropdownMenuItem(value: 'g', child: Text('Grammi (g)')),
                          DropdownMenuItem(value: 'ml', child: Text('Millilitri (ml)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedUnit = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(selectedDate == null 
                        ? 'Nessuna Scadenza' 
                        : 'Scade il: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setModalState(() => selectedDate = date);
                        }
                      },
                      child: const Text('Seleziona Data'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Note aggiuntive (opzionale)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      final quantity = double.tryParse(quantityCtrl.text) ?? 0;

                      final newItem = PantryItem(
                        id: item?.id ?? '',
                        name: name,
                        category: selectedCategory,
                        quantity: quantity,
                        unit: selectedUnit,
                        expiryDate: selectedDate,
                        notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                      );

                      if (item == null) {
                        Provider.of<AppProvider>(context, listen: false).addPantryItem(newItem);
                      } else {
                        Provider.of<AppProvider>(context, listen: false).updatePantryItem(newItem);
                      }
                      Navigator.pop(ctx);
                    },
                    child: const Text('Salva'),
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
      appBar: AppBar(title: const Text('Dispensa')),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final now = DateTime.now();
          final threshold = now.add(const Duration(days: 3));

          List<PantryItem> filtered = provider.pantryItems.where((p) {
            final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
            
            bool isExpiringSoon = false;
            if (p.expiryDate != null) {
              if (p.expiryDate!.isBefore(threshold) || p.expiryDate!.isBefore(now)) {
                isExpiringSoon = true;
              }
            }

            final matchesExpiry = !_showOnlyExpiring || isExpiringSoon;
            return matchesSearch && matchesExpiry;
          }).toList();

          filtered.sort((a, b) {
            int indexA = pantryCategories.indexOf(a.category);
            int indexB = pantryCategories.indexOf(b.category);
            if (indexA == -1) indexA = pantryCategories.length;
            if (indexB == -1) indexB = pantryCategories.length;
            
            if (indexA != indexB) {
              return indexA.compareTo(indexB);
            }
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Cerca prodotto in dispensa...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('In Scadenza'),
                      selected: _showOnlyExpiring,
                      onSelected: (val) => setState(() => _showOnlyExpiring = val),
                      selectedColor: Colors.orange.shade100,
                      avatar: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
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
                            Icon(Icons.kitchen, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text('La dispensa è vuota.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          
                          bool isExpiringSoon = false;
                          bool isExpired = false;
                          
                          if (item.expiryDate != null) {
                            if (item.expiryDate!.isBefore(now)) {
                              isExpired = true;
                            } else if (item.expiryDate!.isBefore(threshold)) {
                              isExpiringSoon = true;
                            }
                          }

                          Color? cardColor;
                          if (item.quantity <= 0) {
                            cardColor = Colors.red.shade100;
                          } else if (isExpired) {
                            cardColor = Colors.orange.shade100;
                          } else if (isExpiringSoon) {
                            cardColor = Colors.yellow.shade100;
                          }

                          bool showHeader = false;
                          if (index == 0 || filtered[index - 1].category != item.category) {
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
                                    item.category.toUpperCase(),
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            color: cardColor,
                            child: ListTile(
                              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.quantity} ${item.unit}',
                                    style: TextStyle(
                                      color: item.quantity <= 0 ? Colors.red.shade900 : null,
                                      fontWeight: item.quantity <= 0 ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  if (item.expiryDate != null)
                                    Text(
                                      'Scadenza: ${DateFormat('dd/MM/yyyy').format(item.expiryDate!)}',
                                      style: TextStyle(
                                          color: isExpired ? Colors.orange.shade800 : (isExpiringSoon ? Colors.amber.shade800 : Colors.grey.shade600),
                                          fontWeight: isExpired || isExpiringSoon ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  if (item.notes != null && item.notes!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(item.notes!, style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic, fontSize: 12)),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => provider.deletePantryItem(item.id),
                              ),
                              onTap: () => _showItemForm(context, item),
                            ),
                          )
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
        onPressed: () => _showItemForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

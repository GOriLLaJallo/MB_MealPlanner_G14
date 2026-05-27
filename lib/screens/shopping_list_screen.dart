import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/shopping_item.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {

  void _showAddItemForm(BuildContext context, [ShoppingItem? item]) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final quantityCtrl = TextEditingController(text: item?.quantity.toString() ?? '');
    final unitCtrl = TextEditingController(text: item?.unit ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
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
              Text(item == null ? 'Aggiungi alla Lista' : 'Modifica Elemento', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome'),
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
                    child: TextField(
                      controller: unitCtrl,
                      decoration: const InputDecoration(labelText: 'Unità'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final quantity = double.tryParse(quantityCtrl.text) ?? 1.0;

                    final newItem = ShoppingItem(
                      id: item?.id ?? '',
                      name: name,
                      quantity: quantity,
                      unit: unitCtrl.text.trim(),
                      isPurchased: item?.isPurchased ?? false,
                    );

                    if (item == null) {
                      Provider.of<AppProvider>(context, listen: false).addShoppingItem(newItem);
                    } else {
                      Provider.of<AppProvider>(context, listen: false).updateShoppingItem(newItem);
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
      },
    );
  }

  void _generateList() {
    final now = DateTime.now();
    final start = now;
    final end = now.add(const Duration(days: 7));
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Generazione Automatica'),
        content: const Text('Vuoi generare la lista della spesa calcolando gli ingredienti mancanti per i pasti pianificati nei prossimi 7 giorni?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () {
              Provider.of<AppProvider>(context, listen: false).generateShoppingList(start, end);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lista generata con successo!')));
            },
            child: const Text('Genera'),
          ),
        ],
      ),
    );
  }

  void _transferPurchased() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final purchasedCount = provider.shoppingList.where((s) => s.isPurchased).length;
    
    if (purchasedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nessun prodotto acquistato da trasferire.')));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Trasferisci in Dispensa'),
        content: Text('Vuoi trasferire $purchasedCount prodotti acquistati nella dispensa? I prodotti verranno rimossi dalla lista della spesa.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () {
              provider.transferPurchasedToPantry();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prodotti trasferiti con successo!')));
            },
            child: const Text('Trasferisci'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista della Spesa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.move_to_inbox),
            tooltip: 'Trasferisci in Dispensa',
            onPressed: _transferPurchased,
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Genera da Pasti (Feature Avanzata)',
            onPressed: _generateList,
          )
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final list = provider.shoppingList;
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('La tua lista della spesa è vuota.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _generateList, 
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Genera automaticamente'),
                  )
                ],
              ),
            );
          }

          final toBuy = list.where((i) => !i.isPurchased).toList();
          final bought = list.where((i) => i.isPurchased).toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              if (toBuy.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Da Acquistare', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...toBuy.map((item) => _buildListItem(context, item, provider)),
              ],
              if (bought.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Acquistati', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                ...bought.map((item) => _buildListItem(context, item, provider)),
              ]
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, ShoppingItem item, AppProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: item.isPurchased,
          onChanged: (val) {
            provider.toggleShoppingItemPurchased(item.id);
          },
          activeColor: Theme.of(context).primaryColor,
        ),
        title: Text(
          item.name, 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: item.isPurchased ? TextDecoration.lineThrough : null,
            color: item.isPurchased ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text('${item.quantity} ${item.unit}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
              onPressed: () => _showAddItemForm(context, item),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => provider.deleteShoppingItem(item.id),
            ),
          ],
        ),
      ),
    );
  }
}

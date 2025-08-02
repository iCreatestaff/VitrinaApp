import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/item.dart';
import '../models/sell.dart';
import '../models/history_entry.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  late Box<Item> itemBox;
  late Box<Sell> sellBox;
  late Box<HistoryEntry> historyBox;

  final Set<String> selectedItemIds = {};

  double? _minWeight;
  double? _maxWeight;

  @override
  void initState() {
    super.initState();
    itemBox = Hive.box<Item>('items');
    sellBox = Hive.box<Sell>('sales');
    historyBox = Hive.box<HistoryEntry>('history');
  }

  void _toggleSelection(String id) {
    setState(() {
      if (selectedItemIds.contains(id)) {
        selectedItemIds.remove(id);
      } else {
        selectedItemIds.add(id);
      }
    });
  }

  Future<void> _confirmSell() async {
    if (selectedItemIds.isEmpty) return;

    final now = DateTime.now();
    final sellId = const Uuid().v4();

    for (String id in selectedItemIds) {
      final item = itemBox.get(id);
      if (item != null) {
        item.inStock = false;
        await item.save();

        await historyBox.add(HistoryEntry(
          id: const Uuid().v4(),
          operation: 'Vendre',
          date: now,
          itemId: id,
        ));
      }
    }

    final sellRecord = Sell(
      id: sellId,
      itemIds: selectedItemIds.toList(),
      date: now,
    );
    await sellBox.put(sellId, sellRecord);

    Navigator.pop(context);
  }

  void _openFilterDialog() {
    final minController =
        TextEditingController(text: _minWeight?.toString() ?? '');
    final maxController =
        TextEditingController(text: _maxWeight?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Filtrer Par Grammage"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: minController,
                decoration: const InputDecoration(labelText: 'Min Poids (g)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: maxController,
                decoration: const InputDecoration(labelText: 'Max Poids (g)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _minWeight =
                      double.tryParse(minController.text.replaceAll(',', '.'));
                  _maxWeight =
                      double.tryParse(maxController.text.replaceAll(',', '.'));
                });
                Navigator.pop(context);
              },
              child: const Text("Confirmer"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _minWeight = null;
                  _maxWeight = null;
                });
                Navigator.pop(context);
              },
              child: const Text("Effacer"),
            ),
          ],
        );
      },
    );
  }

  List<Item> get _filteredItems {
    return itemBox.values.where((item) => item.inStock).where((item) {
      final w = item.weight;
      if (_minWeight != null && w < _minWeight!) return false;
      if (_maxWeight != null && w > _maxWeight!) return false;
      return true;
    }).toList();
  }

  double get totalWeight {
    return selectedItemIds
        .map((id) => itemBox.get(id)?.weight ?? 0.0)
        .fold(0.0, (a, b) => a + b);
  }

  double get totalPrice {
    return selectedItemIds
        .map((id) => itemBox.get(id)?.price ?? 0.0)
        .fold(0.0, (a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    final inStockItems = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sell Items"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _openFilterDialog,
          ),
        ],
      ),
      body: inStockItems.isEmpty
          ? const Center(child: Text("No items match your filter"))
          : ListView.builder(
              itemCount: inStockItems.length,
              itemBuilder: (context, index) {
                final item = inStockItems[index];
                final isSelected = selectedItemIds.contains(item.id);

                return ListTile(
                  leading: item.photoPath != null && item.photoPath!.isNotEmpty
                      ? Image(
                          image: ResizeImage(FileImage(File(item.photoPath!)),
                              width: 100, height: 100),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text("${item.itemName} (${item.weight}g)"),
                  subtitle: Text("Prix: ${item.price} DT"),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSelection(item.id),
                  ),
                  onTap: () => _toggleSelection(item.id),
                );
              },
            ),
      bottomNavigationBar: selectedItemIds.isNotEmpty
          ? SafeArea(
              minimum: const EdgeInsets.only(bottom: 12), // push up a bit
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.inventory_2, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '${selectedItemIds.length} Element(s) Choisi(s)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total: ${totalWeight.toStringAsFixed(2)}g | ${totalPrice.toStringAsFixed(2)} DT',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _confirmSell,
                      icon: const Icon(Icons.check),
                      label: const Text("Confirmer"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vitrina_app/screens/history_screen.dart';
import 'package:vitrina_app/screens/sell_screen.dart';
import '../models/item.dart';
import '../widgets/item_card.dart';
import 'add_edit_item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Item> itemBox;

  double? _minWeight;
  double? _maxWeight;
  bool _showSold = false;

  @override
  void initState() {
    super.initState();
    itemBox = Hive.box<Item>('items');
  }

  void _navigateToAddItem() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditItemScreen()),
    ).then((_) => setState(() {}));
  }

  void _openFilterDialog() {
    final minController =
        TextEditingController(text: _minWeight?.toString() ?? '');
    final maxController =
        TextEditingController(text: _maxWeight?.toString() ?? '');
    bool tempShowSold = _showSold;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Filtrer Elements"),
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
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Voir Elements Vendus"),
                  Switch(
                    value: tempShowSold,
                    onChanged: (value) {
                      setState(() {
                        tempShowSold = value;
                        _showSold = value;
                      });
                      Navigator.pop(context);
                      _openFilterDialog();
                    },
                  ),
                ],
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
                  _showSold = tempShowSold;
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
                  _showSold = false;
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
    return itemBox.values
        .where((item) => _showSold ? !item.inStock : item.inStock)
        .where((item) {
      final w = item.weight;
      if (_minWeight != null && w < _minWeight!) return false;
      if (_maxWeight != null && w > _maxWeight!) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 2,
        title: Text(
          _showSold ? "Bijoux Vendus" : "Vitrine Bijoux",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _openFilterDialog,
          ),
        ],
      ),
      body: filteredItems.isEmpty
          ? const Center(child: Text("Pas d'element pour ce filtre"))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.80,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: ItemCard(
                    item: item,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditItemScreen(item: item),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildFAB(Icons.add, Colors.amber, "Add", _navigateToAddItem),
          const SizedBox(height: 12),
          _buildFAB(Icons.sell, Colors.red, "Sell", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SellScreen()),
            ).then((_) => setState(() {}));
          }),
          const SizedBox(height: 12),
          _buildFAB(Icons.history, Colors.grey, "History", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ).then((_) => setState(() {}));
          }),
        ],
      ),
    );
  }

  Widget _buildFAB(
      IconData icon, Color color, String tooltip, VoidCallback onTap) {
    return FloatingActionButton(
      heroTag: tooltip,
      backgroundColor: color,
      tooltip: tooltip,
      onPressed: onTap,
      child: Icon(icon),
    );
  }
}

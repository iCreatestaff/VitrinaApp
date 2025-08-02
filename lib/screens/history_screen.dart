import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../models/history_entry.dart';
import '../models/item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTimeRange? _selectedDateRange;

  void _showItemDetails(BuildContext context, Item item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: Text(
                item.itemName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (item.photoPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(item.photoPath!),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            _buildInfoRow("Poids", "${item.weight} g"),
            _buildInfoRow("Prix", "${item.price} DT"),
            _buildInfoRow("Calibre", item.caliber),
            _buildInfoRow("Timbre", item.stamp),
            _buildInfoRow("Type Vendeur", item.sellerType),
            _buildInfoRow("CIN Vendeur", item.nationalCardNumber),
            _buildInfoRow("Page de la Signature", item.signaturePageReference),
            const SizedBox(height: 12),
            const Text(
              "Info Extra:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              item.details,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _selectedDateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyBox = Hive.box<HistoryEntry>('history');
    final itemBox = Hive.box<Item>('items');

    // Get all entries, sorted descending by date
    final allEntries = historyBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Filter entries by selected date range if set
    final entries = _selectedDateRange == null
        ? allEntries
        : allEntries.where((entry) {
            return entry.date.isAfter(_selectedDateRange!.start
                    .subtract(const Duration(days: 1))) &&
                entry.date.isBefore(
                    _selectedDateRange!.end.add(const Duration(days: 1)));
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique"),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: "Filter by date range",
            onPressed: _pickDateRange,
          ),
          if (_selectedDateRange != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: "Clear date filter",
              onPressed: () {
                setState(() {
                  _selectedDateRange = null;
                });
              },
            ),
        ],
      ),
      body: entries.isEmpty
          ? const Center(child: Text("pas d'historique"))
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final item = itemBox.get(entry.itemId);
                final itemName = item?.itemName ?? "Element Unconnu";
                final dateStr =
                    DateFormat('yyyy-MM-dd – HH:mm').format(entry.date);

                Icon icon;
                Color color;

                switch (entry.operation) {
                  case 'Ajouter':
                    icon = const Icon(Icons.add, color: Colors.green);
                    color = Colors.green.shade50;
                    break;
                  case 'Modifier':
                    icon = const Icon(Icons.edit, color: Colors.orange);
                    color = Colors.orange.shade50;
                    break;
                  case 'Vendre':
                    icon = const Icon(Icons.sell, color: Colors.redAccent);
                    color = Colors.red.shade50;
                    break;
                  case 'Effacer':
                    icon = const Icon(Icons.delete, color: Colors.grey);
                    color = Colors.grey.shade200;
                    break;
                  default:
                    icon = const Icon(Icons.info);
                    color = Colors.white;
                }

                return Card(
                  color: color,
                  child: ListTile(
                    leading: icon,
                    title: Text("${entry.operation.toUpperCase()} - $itemName"),
                    subtitle: Text(dateStr),
                    onTap: item != null
                        ? () => _showItemDetails(context, item)
                        : null,
                  ),
                );
              },
            ),
    );
  }
}

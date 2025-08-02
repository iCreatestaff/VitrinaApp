import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:vitrina_app/screens/image_preview_screen.dart';
import '../models/item.dart';
import '../models/history_entry.dart';

class AddEditItemScreen extends StatefulWidget {
  final Item? item;

  const AddEditItemScreen({super.key, this.item});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  String? _photoPath;
  final _itemNameController = TextEditingController();
  final _nationalCardController = TextEditingController();
  final _signaturePageController = TextEditingController();
  final _sellerTypeController = TextEditingController();

  final _sellerNameController = TextEditingController();
  final _weightController = TextEditingController();
  final _priceController = TextEditingController();
  final _caliberController = TextEditingController();
  final _stampController = TextEditingController();
  final _detailsController = TextEditingController();

  // Helper method for consistent label style
  InputDecoration _buildDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _itemNameController.text = widget.item?.itemName ?? '';
      _nationalCardController.text = widget.item?.nationalCardNumber ?? '';
      _signaturePageController.text = widget.item?.signaturePageReference ?? '';
      _sellerTypeController.text = widget.item?.sellerType ?? '';

      _photoPath = widget.item!.photoPath;
      _sellerNameController.text = widget.item!.sellerName;
      _weightController.text = widget.item!.weight.toString();
      _priceController.text = widget.item!.price.toString();
      _caliberController.text = widget.item!.caliber;
      _stampController.text = widget.item!.stamp;
      _detailsController.text = widget.item!.details;
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _photoPath = picked.path;
      });
    }
  }

  void _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final itemBox = Hive.box<Item>('items');
    final historyBox = Hive.box<HistoryEntry>('history');
    final now = DateTime.now();
    final id = widget.item?.id ?? const Uuid().v4();

    final newItem = Item(
      id: id,
      itemName: _itemNameController.text,
      photoPath: _photoPath,
      weight:
          double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 0.0,
      price: double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0,
      inStock: true,
      sellerName: _sellerNameController.text,
      caliber: _caliberController.text,
      stamp: _stampController.text,
      details: _detailsController.text,
      nationalCardNumber: _nationalCardController.text,
      signaturePageReference: _signaturePageController.text,
      sellerType: _sellerTypeController.text,
    );

    if (widget.item == null) {
      await itemBox.put(id, newItem);
      await historyBox.add(
        HistoryEntry(
          id: const Uuid().v4(),
          operation: "Ajouter",
          date: now,
          itemId: id,
        ),
      );
    } else {
      await itemBox.put(id, newItem);
      await historyBox.add(
        HistoryEntry(
          id: const Uuid().v4(),
          operation: "Modifier",
          date: now,
          itemId: id,
        ),
      );
    }

    Navigator.pop(context);
  }

  void _confirmDelete() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirmer la suppression"),
      content: const Text("Voulez-vous vraiment supprimer cet élément ?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("Supprimer"),
        ),
      ],
    ),
  );

  if (confirm == true) {
    _deleteItem();
  }
}


  void _deleteItem() async {
    if (widget.item == null) return;

    final itemBox = Hive.box<Item>('items');
    final historyBox = Hive.box<HistoryEntry>('history');

    await itemBox.delete(widget.item!.id);
    await historyBox.add(
      HistoryEntry(
        id: const Uuid().v4(),
        operation: "Effacer",
        date: DateTime.now(),
        itemId: widget.item!.id,
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _sellerNameController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    _caliberController.dispose();
    _stampController.dispose();
    _detailsController.dispose();
    _nationalCardController.dispose();
    _signaturePageController.dispose();
    _sellerTypeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier Element' : 'Ajouter Element'),
        actions: [
  if (isEditing)
    IconButton(
      onPressed: _confirmDelete,
      icon: const Icon(Icons.delete),
    ),
],

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  if (_photoPath != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ImagePreviewScreen(imagePath: _photoPath!),
                      ),
                    );
                  }
                },
                child: Stack(
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[300],
                      ),
                      child: _photoPath == null
                          ? const Center(child: Text("clique pour choisir"))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_photoPath!),
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: _pickImage,
                        tooltip: "Change Image",
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sellerNameController,
                decoration: _buildDecoration('Nom du Vendeur'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _nationalCardController,
                decoration: _buildDecoration('Carte d identité nationale'),
              ),
              TextFormField(
                controller: _signaturePageController,
                decoration: _buildDecoration('Signature Page Reference'),
              ),
              DropdownButtonFormField<String>(
                value: _sellerTypeController.text.isNotEmpty
                    ? _sellerTypeController.text
                    : null,
                decoration: _buildDecoration('Type Vendeur'),
                items: const [
                  DropdownMenuItem(value: 'client', child: Text('Client')),
                  DropdownMenuItem(
                      value: 'fournisseur', child: Text('Fournisseur')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sellerTypeController.text = value!;
                  });
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select a seller type'
                    : null,
              ),
              DropdownButtonFormField<String>(
                value: _itemNameController.text.isNotEmpty
                    ? _itemNameController.text
                    : null,
                decoration: _buildDecoration('Nom d element'),
                items: const [
                  DropdownMenuItem(
                      value: 'Soulitaire', child: Text('Soulitaire')),
                  DropdownMenuItem(value: 'Bracelet', child: Text('Bracelet')),
                  DropdownMenuItem(value: 'Chaine', child: Text('Chaine')),
                  DropdownMenuItem(value: 'Collier', child: Text('Collier')),
                  DropdownMenuItem(value: 'Alliance', child: Text('Alliance')),
                  DropdownMenuItem(
                      value: 'Boucles d oreilles',
                      child: Text('Boucles d oreilles')),
                  DropdownMenuItem(value: 'Anneau', child: Text('Anneau')),
                ],
                onChanged: (value) {
                  setState(() {
                    _itemNameController.text = value!;
                  });
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select a Item Name'
                    : null,
              ),
              TextFormField(
                controller: _weightController,
                decoration: _buildDecoration('Poids (g)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              TextFormField(
                controller: _priceController,
                decoration: _buildDecoration('Prix'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              TextFormField(
                controller: _caliberController,
                decoration: _buildDecoration('Calibre'),
              ),
              TextFormField(
                controller: _stampController,
                decoration: _buildDecoration('Timbre'),
              ),
              TextFormField(
                controller: _detailsController,
                decoration: _buildDecoration('Info Extra'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveItem,
                child: const Text("Sauvgarder"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

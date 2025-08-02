import 'dart:io';
import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (item.photoPath != null && item.photoPath!.isNotEmpty) {
      final file = File(item.photoPath!);
      if (file.existsSync()) {
        imageWidget = Image(
          image: ResizeImage(FileImage(file),
              width: 300), // Resize width only, keeps aspect ratio
          fit: BoxFit.cover, // crop to fill without stretching
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      } else {
        imageWidget = _placeholder();
      }
    } else {
      imageWidget = _placeholder();
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: imageWidget,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.weight.toStringAsFixed(2)} g',
                    style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 17),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.price.toStringAsFixed(2)} DT',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 37, 171, 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.image_not_supported,
        size: 50,
        color: Colors.grey,
      ),
    );
  }
}

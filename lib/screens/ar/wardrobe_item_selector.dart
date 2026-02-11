import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/clothing_item.dart';
import '../../services/wardrobe_service.dart';

class WardrobeItemSelector extends StatelessWidget {
  final Function(String) onItemSelected;

  const WardrobeItemSelector({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    final wardrobeService = context.watch<WardrobeService>();
    const userId = '1234'; // Replace with actual user ID

    return StreamBuilder<List<ClothingItem>>(
      stream: wardrobeService.getItems(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!;

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: Image.network(item.thumbnailUrl, width: 50, height: 50, fit: BoxFit.cover),
              title: Text(item.category),
              subtitle: Text(item.brand.isNotEmpty ? item.brand : 'Generic'),
              onTap: () => onItemSelected(item.imageUrl),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/clothing_item.dart';
import '../../services/wardrobe_service.dart';
import '../../auth/auth_service.dart';

class OutfitBuilderScreen extends StatefulWidget {
  const OutfitBuilderScreen({super.key});

  @override
  State<OutfitBuilderScreen> createState() => _OutfitBuilderScreenState();
}

class _OutfitBuilderScreenState extends State<OutfitBuilderScreen> {
  ClothingItem? _selectedTop;
  ClothingItem? _selectedBottom;
  ClothingItem? _selectedShoes;
  ClothingItem? _selectedAccessory;
  double _outfitScore = 0.0;

  void _calculateOutfitScore() {
    double score = 0.0;
    int itemCount = 0;
    
    if (_selectedTop != null) { score += 0.8; itemCount++; }
    if (_selectedBottom != null) { score += 0.7; itemCount++; }
    if (_selectedShoes != null) { score += 0.6; itemCount++; }
    if (_selectedAccessory != null) { score += 0.9; itemCount++; }
    
    setState(() {
      _outfitScore = itemCount > 0 ? score / itemCount : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final wardrobeService = context.watch<WardrobeService>();
    final userId = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _outfitScore > 0.5 ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Outfit saved!')),
              );
            } : null,
          ),
        ],
      ),
      body: Column(
        children: [
          // YELLOW BOX - Outfit Builder Area
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF8FF),
                border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Outfit Score: ${(_outfitScore * 100).toInt()}%',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildDropZone('accessory', _selectedAccessory, Icons.watch),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Expanded(child: _buildDropZone('top', _selectedTop, Icons.checkroom)),
                              Expanded(child: _buildDropZone('bottom', _selectedBottom, Icons.checkroom)),
                              Expanded(child: _buildDropZone('shoes', _selectedShoes, Icons.sports_soccer)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _buildDropZone('accessory', _selectedAccessory, Icons.watch),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // GREEN BOX - Clothing Carousel
          Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8FF),
              border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: StreamBuilder<List<ClothingItem>>(
              stream: userId != null ? wardrobeService.getItems(userId) : null,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final items = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 8),
                      child: Draggable<ClothingItem>(
                        data: item,
                        feedback: Material(
                          child: Container(
                            width: 100,
                            height: 140,
                            child: _buildMiniCard(item),
                          ),
                        ),
                        childWhenDragging: Opacity(opacity: 0.5, child: _buildMiniCard(item)),
                        child: _buildMiniCard(item),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone(String category, ClothingItem? item, IconData icon) {
    return DragTarget<ClothingItem>(
      onAccept: (droppedItem) {
        setState(() {
          switch (category) {
            case 'top': _selectedTop = droppedItem; break;
            case 'bottom': _selectedBottom = droppedItem; break;
            case 'shoes': _selectedShoes = droppedItem; break;
            case 'accessory': _selectedAccessory = droppedItem; break;
          }
        });
        _calculateOutfitScore();
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: candidateData.isNotEmpty ? const Color(0xFF8B5CF6) : Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(8),
            color: candidateData.isNotEmpty ? const Color(0xFF8B5CF6).withValues(alpha: 0.1) : Colors.grey[100],
          ),
          child: item != null ? _buildMiniCard(item) : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: Colors.grey),
                Text(category.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniCard(ClothingItem item) {
    return Card(
      child: Column(
        children: [
          Container(
            height: 20,
            width: double.infinity,
            color: Colors.black87,
            child: Center(
              child: Text(
                item.brand.isNotEmpty ? item.brand : 'Brand',
                style: const TextStyle(color: Colors.white, fontSize: 8),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.blue,
              child: item.thumbnailUrl.isNotEmpty
                  ? Image.network(item.thumbnailUrl, fit: BoxFit.cover)
                  : const Icon(Icons.checkroom, color: Colors.white),
            ),
          ),
          Container(
            height: 20,
            width: double.infinity,
            color: Colors.red,
            child: Center(
              child: Text(
                item.category.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
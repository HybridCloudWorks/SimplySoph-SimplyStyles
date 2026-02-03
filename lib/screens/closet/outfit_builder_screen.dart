import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_service.dart';
import '../../models/clothing_item.dart';
import '../../services/wardrobe_service.dart';
import '../components/network_image_with_retry.dart';

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

    if (_selectedTop != null) {
      score += 0.8;
      itemCount++;
    }
    if (_selectedBottom != null) {
      score += 0.7;
      itemCount++;
    }
    if (_selectedShoes != null) {
      score += 0.6;
      itemCount++;
    }
    if (_selectedAccessory != null) {
      score += 0.9;
      itemCount++;
    }

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
            onPressed: _outfitScore > 0.5
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Outfit saved!')),
                    );
                  }
                : null,
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
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildDropZone(
                              'accessory', _selectedAccessory, Icons.watch),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Expanded(
                                  child: _buildDropZone(
                                      'top', _selectedTop, Icons.checkroom)),
                              Expanded(
                                  child: _buildDropZone('bottom',
                                      _selectedBottom, Icons.checkroom)),
                              Expanded(
                                  child: _buildDropZone('shoes', _selectedShoes,
                                      Icons.sports_soccer)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _buildDropZone(
                              'accessory', _selectedAccessory, Icons.watch),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Drag items from below or click to remove',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
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
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                        'Add items to your closet to start building outfits'),
                  );
                }

                return _ClothingCarousel(items: items);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone(String category, ClothingItem? item, IconData icon) {
    return DragTarget<ClothingItem>(
      onAcceptWithDetails: (details) {
        final droppedItem = details.data;

        // Validate category matching
        // Map logical categories to generic ones if needed, or stick to strict matching
        bool isMatch = false;
        if (category == 'accessory') {
           isMatch = droppedItem.category == 'accessory';
        } else if (category == 'top') {
           isMatch = droppedItem.category == 'top' || droppedItem.category == 'outerwear' || droppedItem.category == 'dress';
        } else {
           isMatch = droppedItem.category == category;
        }

        if (!isMatch) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Cannot put ${droppedItem.category} in $category zone'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        setState(() {
          switch (category) {
            case 'top':
              _selectedTop = droppedItem;
              break;
            case 'bottom':
              _selectedBottom = droppedItem;
              break;
            case 'shoes':
              _selectedShoes = droppedItem;
              break;
            case 'accessory':
              _selectedAccessory = droppedItem;
              break;
          }
        });
        _calculateOutfitScore();
      },
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: () {
            if (item != null) {
              setState(() {
                switch (category) {
                  case 'top':
                    _selectedTop = null;
                    break;
                  case 'bottom':
                    _selectedBottom = null;
                    break;
                  case 'shoes':
                    _selectedShoes = null;
                    break;
                  case 'accessory':
                    _selectedAccessory = null;
                    break;
                }
                _calculateOutfitScore();
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(
                  color: candidateData.isNotEmpty
                      ? const Color(0xFF8B5CF6)
                      : Colors.grey,
                  width: 2),
              borderRadius: BorderRadius.circular(8),
              color: candidateData.isNotEmpty
                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
                  : Colors.grey[100],
            ),
            child: item != null
                ? _buildMiniCard(item)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 32, color: Colors.grey),
                        Text(category.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildMiniCard(ClothingItem item) {
    return Card(
      clipBehavior: Clip.antiAlias,
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
              color: Colors.white,
              child: item.thumbnailUrl.isNotEmpty
                  ? NetworkImageWithRetry(
                      imageUrl: item.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                      errorWidget: const Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey, size: 20),
                      ),
                    )
                  : const Center(child: Icon(Icons.checkroom, color: Colors.grey)),
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

class _ClothingCarousel extends StatefulWidget {
  final List<ClothingItem> items;

  const _ClothingCarousel({required this.items});

  @override
  State<_ClothingCarousel> createState() => _ClothingCarouselState();
}

class _ClothingCarouselState extends State<_ClothingCarousel> {
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;

  void _scrollToIndex(int index) {
    if (index < 0 || index >= widget.items.length) return;

    setState(() => _currentIndex = index);
    _scrollController.animateTo(
      index * 128.0, // 120 width + 8 padding
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left arrow
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _currentIndex > 0
              ? () => _scrollToIndex(_currentIndex - 1)
              : null,
        ),

        // Carousel
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return SizedBox(
                width: 120,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Draggable<ClothingItem>(
                    data: item,
                    feedback: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 100,
                        height: 140,
                        child: _buildMiniCard(item),
                      ),
                    ),
                    childWhenDragging:
                        Opacity(opacity: 0.5, child: _buildMiniCard(item)),
                    child: _buildMiniCard(item),
                  ),
                ),
              );
            },
          ),
        ),

        // Right arrow
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentIndex < widget.items.length - 1
              ? () => _scrollToIndex(_currentIndex + 1)
              : null,
        ),
      ],
    );
  }

  Widget _buildMiniCard(ClothingItem item) {
    return Card(
      clipBehavior: Clip.antiAlias,
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
              color: Colors.white,
              child: item.thumbnailUrl.isNotEmpty
                  ? NetworkImageWithRetry(
                      imageUrl: item.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                      errorWidget: const Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey, size: 20),
                      ),
                    )
                  : const Center(child: Icon(Icons.checkroom, color: Colors.grey)),
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

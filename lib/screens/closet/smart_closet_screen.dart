import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_service.dart';
import '../../models/clothing_item.dart';
import '../../services/image_service.dart';
import '../../services/wardrobe_service.dart';
import '../scanner/add_item_screen.dart';
import 'item_detail_screen.dart';

class SmartClosetScreen extends StatelessWidget {
  const SmartClosetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final wardrobeService = context.watch<WardrobeService>();
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Closet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddItemScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ClothingItem>>(
        stream: wardrobeService.getItems(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.checkroom, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Your closet is empty'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddItemScreen()),
                      );
                    },
                    child: const Text('Add Your First Item'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Improved aspect ratio
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _ItemCard(item: item);
            },
          );
        },
      ),
    );
  }
}

class _ItemCard extends StatefulWidget {
  final ClothingItem item;

  const _ItemCard({required this.item});

  @override
  State<_ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<_ItemCard> {
  String? _imageUrl;
  bool _isLoadingUrl = false;

  @override
  void initState() {
    super.initState();
    _loadImageUrl();
  }

  @override
  void didUpdateWidget(_ItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.thumbnailUrl != widget.item.thumbnailUrl) {
      _loadImageUrl();
    }
  }

  Future<void> _loadImageUrl() async {
    if (widget.item.thumbnailUrl.isEmpty) {
      setState(() => _imageUrl = null);
      return;
    }

    setState(() => _isLoadingUrl = true);

    try {
      // First try the stored URL
      setState(() => _imageUrl = widget.item.thumbnailUrl);
    } catch (e) {
      debugPrint('Error setting initial URL: $e');
    } finally {
      setState(() => _isLoadingUrl = false);
    }
  }

  Future<void> _getFreshUrl() async {
    if (!mounted) return;

    setState(() => _isLoadingUrl = true);

    try {
      final imageService = context.read<ImageService>();
      final userId = context.read<AuthService>().currentUser?.uid;

      if (userId != null && widget.item.thumbnailUrl.isNotEmpty) {
        // Extract the path from the thumbnail URL
        final uri = Uri.parse(widget.item.thumbnailUrl);
        final pathSegments = uri.pathSegments;

        // Find the thumbnail path (should be users/{userId}/wardrobe/thumbnails/{itemId}_thumb.jpg)
        final thumbnailIndex = pathSegments.indexOf('thumbnails');
        if (thumbnailIndex >= 0 && thumbnailIndex < pathSegments.length - 1) {
          final thumbnailPath =
              pathSegments.sublist(thumbnailIndex - 1).join('/');
          final freshUrl =
              await imageService.getFreshDownloadUrl(userId, thumbnailPath);

          if (freshUrl != null && mounted) {
            setState(() => _imageUrl = freshUrl);
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting fresh URL: $e');
    } finally {
      if (mounted) setState(() => _isLoadingUrl = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAnalyzing = widget.item.status == 'uploading' || widget.item.status == 'analyzing';

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItemDetailScreen(item: widget.item),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_isLoadingUrl)
                    const Center(child: CircularProgressIndicator())
                  else if (_imageUrl != null && _imageUrl!.isNotEmpty)
                    Image.network(
                      _imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint(
                            'Failed to load thumbnail: $_imageUrl, error: $error');
                        // Try to get a fresh URL on error
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _getFreshUrl();
                        });
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.image_not_supported,
                                    size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  'Image unavailable',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_not_supported,
                                size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'No image',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Analyzing Overlay
                  if (isAnalyzing)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 8),
                            Text(
                              'AI Analyzing...',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Persona Match Indicator
                  if (!isAnalyzing && widget.item.personaIds.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(widget.item.personaIds.length * 20).clamp(0, 100)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand and Model or just category if generic
                  if (widget.item.brand.isNotEmpty)
                    Text(
                      widget.item.brand,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      widget.item.category[0].toUpperCase() +
                          widget.item.category.substring(1), // Title case
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 4),
                  // Category type in bottom right
                  Text(
                    widget.item.category[0].toUpperCase() +
                        widget.item.category.substring(1), // Title case
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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
}

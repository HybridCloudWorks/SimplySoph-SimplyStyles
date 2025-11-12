import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../auth/auth_service.dart';
import '../../models/clothing_item.dart';
import '../../services/wardrobe_service.dart';
import '../../services/algolia_service.dart';
import '../../services/bitly_service.dart';
import '../scanner/add_item_screen.dart';

class SmartClosetWithSearchScreen extends StatefulWidget {
  const SmartClosetWithSearchScreen({super.key});

  @override
  State<SmartClosetWithSearchScreen> createState() => _SmartClosetWithSearchScreenState();
}

class _SmartClosetWithSearchScreenState extends State<SmartClosetWithSearchScreen> {
  final _searchController = TextEditingController();
  final _algolia = AlgoliaService();
  final _bitly = BitlyService();
  List<Map<String, dynamic>>? _searchResults;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _algolia.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = null);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final results = await _algolia.search(query);
      setState(() => _searchResults = results);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _shareWardrobe() async {
    final userId = context.read<AuthService>().currentUser?.uid;
    if (userId == null) return;

    final shortUrl = await _bitly.shareOutfit(userId);
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Your Wardrobe'),
        content: SelectableText(shortUrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final wardrobeService = context.watch<WardrobeService>();
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Closet'),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareWardrobe),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddItemScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search wardrobe...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _performSearch,
            ),
          ),
          Expanded(
            child: _searchResults != null
                ? _buildSearchResults()
                : StreamBuilder<List<ClothingItem>>(
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
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AddItemScreen()),
                                ),
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
                          childAspectRatio: 0.75,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) => _ItemCard(item: items[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults!.isEmpty) {
      return const Center(child: Text('No results found'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _searchResults!.length,
      itemBuilder: (context, index) {
        final item = _searchResults![index];
        return Card(
          child: Column(
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: item['thumbnailUrl'] ?? '',
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const Icon(Icons.error),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  item['category']?.toString().toUpperCase() ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ClothingItem item;
  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: item.thumbnailUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.category.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                if (item.brand.isNotEmpty) Text(item.brand, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/integration_models.dart';
import '../../services/cloud_functions_service.dart';

class ShoppingSearchWidget extends StatefulWidget {
  const ShoppingSearchWidget({super.key});

  @override
  State<ShoppingSearchWidget> createState() => _ShoppingSearchWidgetState();
}

class _ShoppingSearchWidgetState extends State<ShoppingSearchWidget> {
  final CloudFunctionsService _functionsService = CloudFunctionsService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  List<ProductResult> _results = [];
  String? _error;
  String _selectedSource = 'All'; // All, Shein, Zappos

  Future<void> _search() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _results = [];
    });

    try {
      final futures = <Future<List<dynamic>>>[];

      if (_selectedSource == 'All' || _selectedSource == 'Shein') {
        futures.add(_functionsService.searchShein(_searchController.text));
      }
      if (_selectedSource == 'All' || _selectedSource == 'Zappos') {
        futures.add(_functionsService.searchZappos(_searchController.text));
      }

      final products = <ProductResult>[];

      // Process results safely
      if (_selectedSource == 'All' || _selectedSource == 'Shein') {
        try {
          final sheinRaw =
              await _functionsService.searchShein(_searchController.text);
          products
              .addAll(sheinRaw.map((json) => ProductResult.fromShein(json)));
        } catch (e) {
          // Silently handle Shein search errors
        }
      }

      if (_selectedSource == 'All' || _selectedSource == 'Zappos') {
        try {
          final zapposRaw =
              await _functionsService.searchZappos(_searchController.text);
          products
              .addAll(zapposRaw.map((json) => ProductResult.fromZappos(json)));
        } catch (e) {
          // Silently handle Zappos search errors
        }
      }

      setState(() {
        _results = products;
        if (products.isEmpty) {
          _error = 'No results found';
        }
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar & Filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search Products',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_bag),
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedSource,
                items: ['All', 'Shein', 'Zappos']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedSource = v!),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _isLoading ? null : _search,
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Results Grid
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null && _results.isEmpty)
            Expanded(
                child: Center(
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red))))
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final product = _results[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: product.imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: product.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (context, url) =>
                                      Container(color: Colors.grey[200]),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                )
                              : Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.source,
                                style: TextStyle(
                                  color: product.source == 'Shein'
                                      ? Colors.pink
                                      : Colors.blue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.price,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

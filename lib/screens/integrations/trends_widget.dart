import 'package:flutter/material.dart';

import '../../models/integration_models.dart';
import '../../services/cloud_functions_service.dart';

class TrendsWidget extends StatefulWidget {
  const TrendsWidget({super.key});

  @override
  State<TrendsWidget> createState() => _TrendsWidgetState();
}

class _TrendsWidgetState extends State<TrendsWidget> {
  final CloudFunctionsService _functionsService = CloudFunctionsService();
  final TextEditingController _searchController =
      TextEditingController(text: 'fashion trends');

  bool _isLoading = false;
  TrendData? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTrends();
  }

  Future<void> _fetchTrends() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _functionsService.getFashionTrends(
        keyword: _searchController.text,
      );
      setState(() {
        _data = TrendData.fromJson(data);
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
          // Search Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Trend Keyword',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.trending_up),
                  ),
                  onSubmitted: (_) => _fetchTrends(),
                ),
              ),
              const SizedBox(width: 16),
              IconButton.filled(
                onPressed: _isLoading ? null : _fetchTrends,
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)))
          else if (_data != null)
            Expanded(
              child: ListView(
                children: [
                  _buildSectionTitle('Interest Over Time (Last 30 Days)'),
                  SizedBox(
                    height: 200,
                    child: _buildTrendChart(_data!.interestOverTime),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Related Queries'),
                  ..._data!.relatedQueries.map((q) => ListTile(
                        leading: const Icon(Icons.search, size: 20),
                        title: Text(q['query'] ?? ''),
                        trailing: Text('${q['value']}%'),
                        dense: true,
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTrendChart(List<dynamic> points) {
    if (points.isEmpty) return const Center(child: Text('No data available'));

    // Simple visualization using bars since we don't have a chart library installed yet
    // and I don't want to add dependencies unless necessary.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: points.map((point) {
        final value =
            (point['value'] is List) ? point['value'][0] : point['value'];
        final int val =
            value is int ? value : int.tryParse(value.toString()) ?? 0;

        return Expanded(
          child: Tooltip(
            message: '${point['formattedTime']}: $val',
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              height: (val / 100) * 200, // Normalize to height
              color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
            ),
          ),
        );
      }).toList(),
    );
  }
}

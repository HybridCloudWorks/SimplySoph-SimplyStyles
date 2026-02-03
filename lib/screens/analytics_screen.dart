import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  int _totalUsers = 0;
  int _totalItems = 0;
  int _activeUsers = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final usersSnapshot = await _firestore.collection('users').count().get();
      _totalUsers = usersSnapshot.count ?? 0;

      final itemsSnapshot = await _firestore.collection('wardrobe_items').count().get();
      _totalItems = itemsSnapshot.count ?? 0;

      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final activeSnapshot = await _firestore
          .collection('users')
          .where('lastLoginAt', isGreaterThan: Timestamp.fromDate(weekAgo))
          .count()
          .get();
      _activeUsers = activeSnapshot.count ?? 0;

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMetricCard('Total Users', _totalUsers.toString(), Icons.people),
                const SizedBox(height: 16),
                _buildMetricCard('Total Items', _totalItems.toString(), Icons.checkroom),
                const SizedBox(height: 16),
                _buildMetricCard('Active Users', _activeUsers.toString(), Icons.trending_up),
              ],
            ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
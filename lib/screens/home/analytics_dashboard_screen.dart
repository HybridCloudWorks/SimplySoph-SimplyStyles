import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatCard('Total Users', _getTotalUsers()),
          const SizedBox(height: 16),
          _buildStatCard('Total Items', _getTotalItems()),
          const SizedBox(height: 16),
          _buildStatCard('Total Personas', _getTotalPersonas()),
          const SizedBox(height: 16),
          _buildCategoryChart(),
          const SizedBox(height: 16),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, Future<int> countFuture) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            FutureBuilder<int>(
              future: countFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return Text(
                  '${snapshot.data ?? 0}',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Items by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('wardrobe_items').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final items = snapshot.data!.docs;
                final categories = <String, int>{};
                
                for (var doc in items) {
                  final category = doc.data() as Map<String, dynamic>;
                  final cat = category['category'] ?? 'Unknown';
                  categories[cat] = (categories[cat] ?? 0) + 1;
                }

                return Column(
                  children: categories.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(width: 100, child: Text(entry.key)),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: entry.value / items.length,
                              minHeight: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${entry.value}'),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('wardrobe_items')
                  .orderBy('createdAt', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.add_circle, color: Colors.green),
                      title: Text('${data['category']} added'),
                      subtitle: Text('${data['color']} ${data['style']}'),
                      trailing: Text(_formatTimestamp(data['createdAt'])),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<int> _getTotalUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.length;
  }

  Future<int> _getTotalItems() async {
    final snapshot = await FirebaseFirestore.instance.collection('wardrobe_items').get();
    return snapshot.docs.length;
  }

  Future<int> _getTotalPersonas() async {
    final snapshot = await FirebaseFirestore.instance.collection('style_personas').get();
    return snapshot.docs.length;
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    final date = (timestamp as Timestamp).toDate();
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
